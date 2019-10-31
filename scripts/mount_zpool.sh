#if [ `ip -4 -o addr show dev wlp2s0 | awk '{print }'`
if [ "`ip -4 -o addr show dev wlp2s0 | awk '{print $4}' | awk -F/ '{print $1}'`" == "97.94.130.176" ] ; then
  echo -e "Mounting zpool"
  sudo mount -t nfs 192.168.1.50:/tank /media
else
  echo -e "zpool not avaible"
fi
