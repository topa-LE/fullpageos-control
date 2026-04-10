#!/bin/bash

echo "🌐 API SETUP"

cat <<'EOF' > /usr/local/bin/kiosk-api.py
#!/usr/bin/env python3

from http.server import BaseHTTPRequestHandler, HTTPServer
import os, json, urllib.parse

PORT = 3000
URL_FILE = "/home/kiosk/url.txt"

class Handler(BaseHTTPRequestHandler):

    def do_GET(self):
        path = self.path

        if path.startswith("/api/v1"):
            path = path.replace("/api/v1","",1)

        if path == "/reload":
            os.system("pkill chromium")
            self._json({"status":"reloaded"})

        elif path.startswith("/url="):
            url = urllib.parse.unquote(path.split("=",1)[1])
            open(URL_FILE,"w").write(url)
            os.system("pkill chromium")
            self._json({"status":"updated","url":url})

        elif path == "/status":
            url = open(URL_FILE).read().strip()
            self._json({"status":"ok","url":url})

        elif path == "/health":
            r=os.system("pgrep chromium > /dev/null")
            self._json({"status":"ok","chromium":"running" if r==0 else "stopped"})

        elif path == "/reboot":
            self._json({"status":"rebooting"})
            os.system("reboot")

        else:
            self._json({"service":"kiosk-api","version":"v1.0"})

    def _json(self,data):
        self.send_response(200)
        self.send_header("Content-Type","application/json")
        self.end_headers()
        self.wfile.write((json.dumps(data,indent=2)+"\n").encode())

    def log_message(self,*args): return

HTTPServer(("",PORT),Handler).serve_forever()
EOF

chmod +x /usr/local/bin/kiosk-api.py

cat <<EOF > /etc/systemd/system/kiosk-api.service
[Unit]
Description=Kiosk API
After=network.target

[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/kiosk-api.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kiosk-api
systemctl restart kiosk-api
