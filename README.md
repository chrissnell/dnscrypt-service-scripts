# dnscrypt-service-scripts

Running a highly-available [DNSCrypt](https://www.dnscrypt.org/) endpoint is a bit of a pain in the ass.  To protect your users' privacy, you need to rotate your server keys at least once every 12 hours.  You don't want your service to be unresponsive during key rotation so you must do a fine dance where you swap in a new server instance and remove the old instance once the new one is up and running.   Managing these instances and the re-keying is tough, so I wrote some scripts and systemd units to help.

## Key Rotation
Managing DNSCrypt server keys is tricky.  Keys must be rotated at least twice a day but because clients only check their server for new keys once an hour, the server needs to continue to present older keys for a little while so that clients with an old key don't hang during DNS queries.  The [`dnscrypt-wrapper.sh`](https://github.com/chrissnell/dnscrypt-service-scripts/blob/master/dnscrypt-wrapper.sh) script takes care of the creation/rotating/purging of keys and the starting of the DNSCrypt service (`dnscrypt-wrapper`).

# Installation
As `root`:
```
cp dnscrypt-server-rotate.sh /usr/local/bin/
cp dnscrypt-wrapper.sh /usr/local/bin/
chmod 755 /usr/local/bin/dnscrypt*.sh
cp *.service /usr/lib/systemd/system/
cp *.timer /usr/liib/systemd/system/
systemctl daemon-reload
systemctl enable dnscrypt-server-rotate.timer
systemctl start dnscrypt-server-rotate.timer
systemctl enable dnscrypt-wrapper@a.service
systemctl start dnscrypt-wrapper@a.service
# Test rotation and re-keying manually
/usr/local/bin/dnscrypt-server-rotate.sh
```
