config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}
preserve_perms() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  if [ -e $OLD ]; then
    cp -a $OLD ${NEW}.incoming
    cat $NEW > ${NEW}.incoming
    mv ${NEW}.incoming $NEW
  fi
  config $NEW
}

preserve_perms etc/rc.d/rc.php-fpm.new
preserve_perms etc/cron.hourly/php-sessiongc.new

config etc/php54/php.ini.new
config etc/php54/php-cli.ini.new
config etc/php54/php-fpm.conf.new

if [ -d /etc/monit.d/ ]; then
    if [ ! -r /etc/monit.d/php-fpm ]; then
        cp /usr/doc/php-work-5.4.20/monit.php-fpm /etc/monit.d/php-fpm
    fi
fi
