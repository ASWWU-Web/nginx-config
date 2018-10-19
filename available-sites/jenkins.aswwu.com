upstream jenkins {
    server 127.0.0.1:8102 fail_timeout=0;
}

server {
    listen 80;
    server_name jenkins.aswwu.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443;
    server_name jenkins.aswwu.com;

    ssl on;
    ssl_certificate /etc/letsencrypt/live/jenkins.aswwu.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/jenkins.aswwu.com/privkey.pem;

    location / {
        proxy_set_header        Host $host:$server_port;
        proxy_set_header        X-Real-IP $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto $scheme;
        proxy_redirect http:// https://;
        proxy_pass              http://jenkins;
        # Required for new HTTP-based CLI
        proxy_http_version 1.1;
        # proxy_request_buffering off;  # NEED TO UPGRADE NGINX FOR COMPATIBILITY
        proxy_buffering off; # Required for HTTP-based CLI to work over SSL
        # workaround for https://issues.jenkins-ci.org/browse/JENKINS-45651
        add_header 'X-SSH-Endpoint' 'jenkins.aswwu.com:50000';
    }
}
