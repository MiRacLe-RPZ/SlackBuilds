LOCALCERTDIR=/usr/local/share/ca-certificates
if [ ! -d $LOCALCERTDIR ]; then
    mkdir -p $LOCALCERTDIR
fi

