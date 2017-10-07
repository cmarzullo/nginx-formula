# nginx-formula

configure nginx. Allows for multiple sites broken into multiple config files.  Python (Django) and Ruby FastCGI still need to be configured.  The nginx.conf is not templated yet, so manually modify. HTTPS, Proxy, and FastCGI are disabled by default.

You can toggle the ability to listen on IPv6 per site.

## HTTP
```
nginx:
  enabled: True
  service:
    name: nginx
    state: running
    enable: True
    user: daemon  # optional; defaults to www-data
  sites:
    - fqdn: localhost.local
      ipv6: True
      http:
        port: 80
        root: /var/www/html
        force_https: False
```

## HTTPS with redirect
This is configured to use <fqdn>.crt and <fqdn>.key as the certificate and key, when HTTPS is enabled.  
When HTTPS certificates will be managed by a different state, make sure to set manage_cert to False.
```
nginx:
  enabled: True
  service:
    name: nginx
    state: running
    enable: True
  sites:
    - fqdn: localhost.local
      ipv6: True
      http:
        port: 80
        force_https: True
      https:
        port: 443
        root: /var/www/html
        cert_dir: /etc/ssl/certs
        key_dir: /etc/ssl/private
        manage_cert: False
```

## HTTPS Reverse Proxy
```
nginx:
  enabled: True
  service:
    name: nginx
    state: running
    enable: True
  sites:
    - fqdn: localhost.local
      ipv6: True
      http:
        port: 80
        force_https: True
      https:
        enabled: True
        port: 443
        cert_dir: /etc/ssl/certs
        key_dir: /etc/ssl/private
      proxy:
        name: tomcat
        address: "[::]"
        port: 8080
```

## PHP via FastCGI with FPM-CGI Library
```
nginx:
  enabled: True
  required_pkgs:
    - php5-fpm
  service:
    name: nginx
    state: running
    enable: True
  sites:
    - fqdn: localhost.local
      ipv6: True
      http:
        port: 80
        force_https: True
      https:
        port: 443
        root: /var/www/html
        cert_dir: /etc/ssl/certs
        key_dir: /etc/ssl/private
      fastcgi:
        php: True
        pass: unix:/var/run/php5-fpm.sock
```

## PHP via FastCGI with CGI Library
```
nginx:
  enabled: True
  required_pkgs:
    - php5-cgi
  service:
    name: nginx
    state: running
    enable: True
  sites:
    - fqdn: localhost.local
      ipv6: True
      http:
        port: 80
        force_https: True
      https:
        port: 443
        root: /var/www/html
        cert_dir: /etc/ssl/certs
        key_dir: /etc/ssl/private
      fastcgi:
        php: True
        pass: unix:/var/run/php5-cgi.sock
```

## HTTP Basic Auth
```
nginx:
  enabled: True
  service:
    name: nginx
    state: running
    enable: True
  sites:
    - fqdn: authrealm.local
      http:
        port: 80
        root: /var/www/html
        root_group: root
        enabled: true
      auth_basic:
        realm: 'Password protected'
        uri: /my-protected-uri/
        users:
          regular-guy:
            passwd: 'mysuckypassword'
          admin:
            passwd_scheme: ssha
            passwd: '8D0R+itvu3Z3pR9TobvSaIy481w='
```

## Arbitrary location definitions
key:value definition of locations and settings. Works with http and https definitions.
```
nginx:
  enabled: True
  service:
    name: nginx
    state: running
    enable: True
  sites:
    - fqdn: localhost.local
      ipv6: True
      http:
        port: 80
        force_https: True
      https:
        port: 443
        root: /var/www/html
        cert_dir: /etc/ssl/certs
        key_dir: /etc/ssl/private
        manage_cert: False
      locations:
        /test/:
          root: /tmp/test
        /another/:
          root: /var/www/another
```
