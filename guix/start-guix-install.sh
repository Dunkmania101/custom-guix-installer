#!/usr/bin/env bash

echo "Are you sure you are ready to install the Guix system defined in /mnt/etc/config.scm (y/n)?"
read ans
if [[ "$ans" != "y" ]]; then echo "Aborting as requested!" && exit 0; fi

herd start cow-store /mnt

cp /etc/channels.scm /mnt/etc/
chmod +w /mnt/etc/channels.scm

guix pull --fallback && hash guix
guix time-machine -C /mnt/etc/channels.scm -- system --fallback -kK init /mnt/etc/config.scm /mnt && echo 'Done!' || echo 'Error!'

