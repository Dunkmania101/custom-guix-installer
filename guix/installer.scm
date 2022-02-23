(use-modules
 (gnu)
 (gnu services)
 (gnu system)
 (gnu system install)
 (guix)
 (guix channels)
 (nongnu packages linux))
(use-package-modules linux)
(use-service-modules networking)

(operating-system
  (inherit installation-os)
  (kernel linux)
  (kernel-arguments '("quiet" "net.ifnames=0"))
  (firmware (list linux-firmware))

  (packages
    (append (list
              (specification->package "emacs-no-x-toolkit")
              (specification->package "bash")
              (specification->package "fdisk")
              (specification->package "usb-modeswitch")
              (specification->package "network-manager")
              (specification->package "modem-manager")
              (specification->package "mobile-broadband-provider-info")
              (specification->package "git")
              (specification->package "chrony")
              (specification->package "curl")
              (specification->package "stow")
              (specification->package "vim")
              (specification->package "nss-certs")
              (specification->package "ncurses"))
            (operating-system-packages installation-os)))

  (services
    (append
      (list
       (service network-manager-service-type)
        (simple-service 'channel-file etc-service-type
                        (list `("channels.scm" ,(local-file "channels.scm"))))
        (extra-special-file "/usr/bin/env"
                            (file-append coreutils "/bin/env")))
      (modify-services (operating-system-user-services installation-os)
                       (guix-service-type config => (guix-configuration
                                                      (inherit config)
                                                      (substitute-urls
                                                        (append (list "https://substitutes.nonguix.org")
                                                                %default-substitute-urls))
                                                      (authorized-keys
                                                        (append (list (plain-file "non-guix.pub"
                                                                                  "(public-key 
                                                                                     (ecc 
                                                                                       (curve Ed25519)
                                                                                       (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
                                                                %default-authorized-guix-keys))))))))

