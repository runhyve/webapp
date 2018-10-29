# Setup 
Follow instructions in [vm-webhooks repository](https://gitlab.com/runhyve/vm-webhooks)

# Nginx Reverse Proxy for gotty
```
server {
    server_name "~^port(?P<forwarded_port>\d{5})\.192.168.0.250\.xip\.io$";
    access_log  /var/log/nginx/vm-webhook-gotty-proxy.log;

    location  / { 
        proxy_set_header Authorization "Basic $1";
        rewrite ^/(.*)/tty/?$ / break;
        rewrite ^/(.*)/tty/(.*)$ /$2 break;

        proxy_pass http://127.0.0.1:$forwarded_port; 
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        add_header 'Access-Control-Allow-Origin' 'http://localhost:4000';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'Authorization';
        add_header 'Access-Control-Allow-Credentials' 'true';

        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' 'http://localhost:4000';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'Authorization';
            add_header 'Access-Control-Allow-Credentials' 'true';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        } 
    }
}

```