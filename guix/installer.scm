(use-modules (gnu) (gnu services) (gnu system) (gnu system install) (guix) (guix channels) (nongnu packages linux) (nongnu system linux-initrd))
(use-package-modules mtools linux)
(use-service-modules networking nix)

(define installation-os-dunkmania
(operating-system
  (inherit installation-os)
  (kernel linux)
  (kernel-arguments '("quiet" "net.ifnames=0"))
  (firmware (list linux-firmware))
  (initrd microcode-initrd)

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
          (pam-limits-service ;; This enables JACK to enter realtime mode
           (list
            (pam-limits-entry "@realtime" 'both 'rtprio 99)
            (pam-limits-entry "@realtime" 'both 'memlock 'unlimited)))
          (service nix-service-type))
    (operating-system-user-services installation-os)))))

installation-os-dunkmania
