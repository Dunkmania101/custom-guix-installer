(use-modules (gnu) (gnu services) (gnu system) (gnu system install) (gnu system nss) (guix) (guix channels) (nongnu packages linux) (nongnu system linux-initrd))
(use-package-modules mtools gnome linux)
(use-service-modules
  cups
  desktop
  networking
  ssh
  xorg
  pm
  nix)


(define %xorg-libinput-config
  "Section \"InputClass\"
  Identifier \"Touchpads\"
  Driver \"libinput\"
  MatchDevicePath \"/dev/input/event*\"
  MatchIsTouchpad \"on\"
  Option \"Tapping\" \"on\"
  Option \"TappingDrag\" \"on\"
  Option \"DisableWhileTyping\" \"on\"
  Option \"MiddleEmulation\" \"on\"
  Option \"ScrollMethod\" \"twofinger\"
EndSection
Section \"InputClass\"
  Identifier \"Keyboards\"
  Driver \"libinput\"
  MatchDevicePath \"/dev/input/event*\"
  MatchIsKeyboard \"on\"
EndSection
")

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
            (specification->package "emacs")
            (specification->package "bash")
            (specification->package "git")
            (specification->package "curl")
            (specification->package "stow")
            (specification->package "vim")
            (specification->package "dmenu")
            (specification->package "nix")
            (specification->package "tlp")
            (specification->package "python")
            (specification->package "xf86-input-libinput")
            (specification->package "bluez-alsa")
            (specification->package "bluez")
            (specification->package "gvfs")
            (specification->package "fuse")
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
          (service tlp-service-type
                   (tlp-configuration
                    (cpu-boost-on-ac? #t)
                    (wifi-pwr-on-bat? #t)))
          (pam-limits-service ;; This enables JACK to enter realtime mode
           (list
            (pam-limits-entry "@realtime" 'both 'rtprio 99)
            (pam-limits-entry "@realtime" 'both 'memlock 'unlimited)))
          (service nix-service-type)
          (set-xorg-configuration
           (xorg-configuration
            (extra-config (list %xorg-libinput-config)))))
          (operating-system-user-services installation-os)))))

installation-os-dunkmania
