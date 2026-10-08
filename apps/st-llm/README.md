# SillyTavern

https://github.com/sillytavern/SillyTavern

## First boot and login

Check with:
```sh
sudo cloud-init status --wait
sudo tail -n 80 /var/log/sillytavern-bootstrap.log
sudo systemctl status sillytavern caddy --no-pager
```

- Username: `default-user`
- Initial password:

```sh
sudo cat /var/lib/sillytavern-bootstrap/initial-password
```

## Data and maintenance

- Application: `/opt/sillytavern`
- Config: `/etc/sillytavern/config.yaml`
- Persistent user data: `/var/lib/sillytavern/data`
- Extensions installed for all users: `/opt/sillytavern/public/scripts/extensions/third-party`
- Services: `sillytavern.service`, `caddy.service`

To update to a reviewed release after taking a backup, replace `1.19.0` below with
the desired release tag:

```sh
sudo systemctl stop sillytavern
cd /opt/sillytavern
sudo -u sillytavern git fetch --depth 1 origin tag 1.19.0
sudo -u sillytavern git checkout --detach 1.19.0
sudo -u sillytavern npm ci --omit=dev --no-audit --no-fund
sudo systemctl start sillytavern
sudo journalctl -u sillytavern -n 80 --no-pager
```
