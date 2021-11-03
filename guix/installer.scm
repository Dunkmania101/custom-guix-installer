(use-modules (gnu) (gnu services) (gnu system) (gnu system install) (guix) (guix channels) (nongnu packages linux))
(use-package-modules linux)
(use-service-modules nix)

(define %guix-channels
  (scheme-file
   "channels.scm"
   #~(cons* (channel
             (name 'nonguix)
             (url "https://gitlab.com/nonguix/nonguix")
             (introduction
              (make-channel-introduction
               "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
               (openpgp-fingerprint
                "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
            %default-channels)))

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
    (list (extra-special-file "/etc/guix/channels.scm" %guix-channels)
          (extra-special-file "/usr/bin/env"
                              (file-append coreutils "/bin/env"))
          (service nix-service-type))
    (operating-system-user-services installation-os))))
