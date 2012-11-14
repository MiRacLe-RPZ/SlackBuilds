# Update the desktop database:
if [ -x usr/bin/update-desktop-database ]; then
  chroot . /usr/bin/update-desktop-database usr/share/applications > /dev/null 2>&1
fi
# Update the mime database:
if [ -x usr/bin/update-mime-database ]; then
  chroot . /usr/bin/update-mime-database usr/share/mime >/dev/null 2>&1
fi

# Update hicolor theme cache:
if [ -d usr/share/icons/hicolor ]; then
  if [ -x /usr/bin/gtk-update-icon-cache ]; then
    chroot . /usr/bin/gtk-update-icon-cache -f -t usr/share/icons/hicolor 1> /dev/null 2> /dev/null
  fi
fi
