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

# Keep same perms on rc.graylog2-server.new:
if [ -e etc/rc.d/rc.graylog2-server ]; then
  cp -a etc/rc.d/rc.graylog2-server etc/rc.d/rc.graylog2-server.new.incoming
  cat etc/rc.d/rc.graylog2-server.new > etc/rc.d/rc.graylog2-server.new.incoming
  mv etc/rc.d/rc.graylog2-server.new.incoming etc/rc.d/rc.graylog2-server.new
fi

config etc/rc.d/rc.graylog2-server.new
config etc/graylog2/server/server.conf.new

if [ ! -e /etc/graylog2/server/node-id ]; then
    uuidgen > /etc/graylog2/server/node-id
    chown graylog2:graylog2 /etc/graylog2/server/node-id
fi

ln -s /etc/graylog2/web /usr/share/graylog2/web/conf