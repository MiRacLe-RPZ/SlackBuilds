
if [ -x usr/bin/xdg-icon-resource ]; then
  /usr/bin/xdg-icon-resource forceupdate --theme hicolor 2> /dev/null
fi

if [ -x usr/bin/update-desktop-database ]; then
  /usr/bin/update-desktop-database -q usr/share/applications &> /dev/null
fi

if [ -x usr/bin/update-mime-database ]; then
  /usr/bin/update-mime-database usr/share/mime >/dev/null 2>&1
fi

if [ -x usr/bin/gtk-update-icon-cache ]; then
  for theme in gnome locolor hicolor ; do
    if [ -e usr/share/icons/$theme/icon-theme.cache ]; then
      /usr/bin/gtk-update-icon-cache usr/share/icons/$theme >/dev/null 2>&1
    fi
  done
fi

if [ -x usr/bin/kbuildsycoca4 ]; then
  /usr/bin/kbuildsycoca4 --noincremental >/dev/null 2>&1
fi

( cd usr/bin; rm -f kdesu )
( cd usr/bin; ln -sf kdesudo kdesu )

