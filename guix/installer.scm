(use-modules (gnu) (gnu services) (gnu system) (gnu system install) (guix) (guix channels) (nongnu packages linux))
(use-package-modules linux)
(use-service-modules nix)

(operating-system
  (inherit installation-os)
  (kernel linux)
  (kernel-arguments '("quiet" "net.ifnames=0"))
  (firmware (list linux-firmware))

  (packages
   (append (list
            (specification->package "emacs-no-x-toolkit")
            (specification->package "bash")
            (specification->package "git")
            (specification->package "curl")
            (specification->package "stow")
            (specification->package "vim")
            (specification->package "nix")
            (specification->package "nss-certs")
            (specification->package "ncurses")
            )
           (operating-system-packages installation-os)))

  (services
   (append
    (list (extra-special-file "/etc/guix/channels.scm" (local-file "channels.scm"))
          (simple-service 'channel-file etc-service-type
                          (list `("channels.scm" ,(local-file "channels.scm"))))
          (extra-special-file "/usr/bin/env"
                              (file-append coreutils "/bin/env"))
          (service nix-service-type))
    (operating-system-user-services installation-os))))
