config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    rm $NEW
  fi
}

config etc/ld.so.conf.d/limux.conf.new

# Update ldconfig if this is a fresh install
if [ -x /sbin/ldconfig ]; then
  /sbin/ldconfig 2>/dev/null || true
fi
