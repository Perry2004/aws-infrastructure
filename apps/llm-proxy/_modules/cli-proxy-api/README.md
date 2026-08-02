# LLM Proxy
- [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI)
- [Caddy](https://caddyserver.com/)

## First boot

Retrieve the generated client key:

```sh
sudo cat /var/lib/cliproxyapi/api-key
```

Test authentication locally on the server:

```sh
API_KEY="$(sudo cat /var/lib/cliproxyapi/api-key)"
curl -fsS -H "Authorization: Bearer $API_KEY" http://127.0.0.1:8317/v1/models
unset API_KEY
```

## Provider login

Provider callback ports remain closed in the Lightsail firewall, thus the login must be done through an SSH tunnel.

```sh
sudo -u cliproxy -H /opt/cliproxyapi/cli-proxy-api --config /etc/cliproxyapi/config.yaml -no-browser --codex-login
```

Replace `--codex-login` with `--claude-login` or `--antigravity-login` when needed. Credentials are written to `/var/lib/cliproxyapi/auth` and detected by the running service.
