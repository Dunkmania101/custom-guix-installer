(define-module (dunkmania system install)
  #:use-module (gnu services)
  #:use-module (gnu system)
  #:use-module (gnu system install)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages mtools)
  #:use-module (gnu packages package-management)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (guix)
  #:export (installation-os-dunkmania))

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
            (channel
             (name 'flat)
             (url "https://github.com/flatwhatson/guix-channel.git")
             (introduction
              (make-channel-introduction
               "33f86a4b48205c0dc19d7c036c85393f0766f806"
               (openpgp-fingerprint
                "736A C00E 1254 378B A982  7AF6 9DBE 8265 81B6 4490")))))
            %default-channels))

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

(define %my-desktop-services
  (modify-services %desktop-services
                   (elogind-service-type config =>
                                         (elogind-configuration (inherit config)
                                                                (handle-lid-switch-external-power 'suspend)))
                   (udev-service-type config =>
                                      (udev-configuration (inherit config)
                                                          (rules (cons %backlight-udev-rule
                                                                       (udev-configuration-rules config)))))
                   (network-manager-service-type config =>
                                                 (network-manager-configuration (inherit config)
                                                                                (vpn-plugins (list network-manager-openvpn))))))



(define %backlight-udev-rule
  (udev-rule
   "90-backlight.rules"
   (string-append "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
                  "RUN+=\"/run/current-system/profile/bin/chgrp video /sys/class/backlight/%k/brightness\""
                  "\n"
                  "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
                  "RUN+=\"/run/current-system/profile/bin/chmod g+w /sys/class/backlight/%k/brightness\"")))



(define installation-os-dunkmania
  (operating-system
    (inherit installation-os)
    (kernel linux)
    (firmware (list linux-firmware))
    (initrd microcode-initrd)

    ;; Add the 'net.ifnames' argument to prevent network interfaces
    ;; from having really long names.  This can cause an issue with
    ;; wpa_supplicant when you try to connect to a wifi network.
    (kernel-arguments '("quiet" "modprobe.blacklist=radeon" "net.ifnames=0"))

    (services
     (cons*
      ;; Include the channel file so that it can be used during installation
     (operating-system-user-services installation-os)))

    ;; Add some extra packages useful for the installation process
    (packages
     (append (list
              git curl stow vim emacs-no-x-toolkit

              (specification->package "emacs-pgtk-native-comp")
              (specification->package "bash")
              (specification->package "dmenu")
              (specification->package "nix")
              (specification->package "st")
              (specification->package "xterm")
              (specification->package "tlp")
              (specification->package "python")
              (specification->package "vi")
              (specification->package "xf86-input-libinput")
              (specification->package "bluez-alsa")
              (specification->package "bluez")
              (specification->package "gvfs")
              (specification->package "fuse")
              (specification->package "emacs")
              (specification->package "nss-certs")
              (specification->package "ncurses")
              )
             (operating-system-packages installation-os)))))

    (services
     (append
      (list (operating-system-user-services installation-os)
            (service openssh-service-type)
            (service tor-service-type)
            (service cups-service-type)
            (extra-special-file "/etc/guix/channels.scm" %guix-channels)
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
              (keyboard-layout keyboard-layout)
              (extra-config (list %xorg-libinput-config)))))
      %my-desktop-services))

installation-os-dunkmania
