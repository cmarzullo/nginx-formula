# -*- coding: utf-8 -*-
# vim: ft=yaml
# Custom Pillar Data for nginx

nginx:
  enabled: True
  client_max_body_size: 100M
  service:
    name: nginx
    state: running
    enable: True
    user: daemon
  confd:
    'acls/test-acl.conf':
      source: 'salt://nginx/files/acls.conf.j2'
      header_comment: 'ACLs for backend'
      acls:
        'test1.example.com':
          - '192.168.99.1/32'
        'test2.example.com':
          - '192.168.99.2/32'
    'test/upstream.conf':
      source: 'salt://nginx/files/upstream.conf.j2'
      header_comment: 'upstream settings'
      upstreams:
        middleware:
          comment: 'These handle middleware'
          servers:
            - 'middleware1.example.com'
            - 'middleware2.example.com'
        backend:
          comment: 'These are the backends'
          ip_hash: true
          servers:
            - 'backend1.example.com'
            - 'backend2.example.com'
    'test/client.conf':
      source: 'salt://nginx/files/simple_k_v.conf.j2'
      header_comment: 'client settings'
      globals:
        client_header_buffer_size: '4k'
        large_client_header_buffers: '8 8k'
    'test/ssl.conf':
      source: 'salt://nginx/files/simple_k_v.conf.j2'
      header_comment: 'SSL settings'
      globals:
        sl_certificate: '/opt/public-certs/test.crt'
        ssl_certificate_key: '/opt/public-certs/test.key'
        ssl_dhparam: '/opt/public-certs/dhparams.pem'
        ssl_prefer_server_ciphers: 'on'
        ssl_protocols: 'TLSv1.1 TLSv1.2'
        # note the extra quoting.
        ssl_ciphers: "'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA'"
        ssl_session_cache: 'shared:SSL:10m'
        ssl_session_timeout: '10m'
    'test/proxy.conf':
      #source: 'salt://nginx/files/proxy.conf.j2'
      source: 'salt://nginx/files/simple_k_v.conf.j2'
      header_comment: 'proxy settings'
      globals:
        proxy_buffer_size: '4k'
        proxy_buffers: '4 32k'
        proxy_busy_buffers_size: '64k'
        proxy_temp_file_write_size: '64k'
        proxy_next_upstream: 'error timeout http_503'
        proxy_connect_timeout: '5'
        proxy_read_timeout: '120'
        proxy_set_header:
          - 'Host             $host'
          - 'X-Real-IP        $remote_addr'
          - 'X-Forwarded-For  $proxy_add_x_forwarded_for'
          - 'Scheme           $scheme'

  sites:
    - fqdn: localhost.local
      ipv6: True
      http:
        port: 80
        force_https: False
        root: /var/www/html
        root_group: root
        enabled: true
      https:
        port: 443
        #root: /var/www/html
        cert_dir: /etc/ssl/certs
        key_dir: /etc/ssl/private
        enabled: true
      proxy:
        name: tomcat
        address: "[::]"
        port: 8080
        enabled: true
    - fqdn: sub.localhost.local
      http:
        port: 80
        root: /var/www/html
        root_group: root
        enabled: true
      locations:
        /test/:
          root: /tmp/test
        /another/:
          root: /var/www/another
    - fqdn: authrealm.local
      http:
        port: 80
        root: /var/www/html
        root_group: root
        enabled: true
      auth_basic:
        realm: 'Password protected'
        uri: /
        users:
          regular-guy:
            passwd: 'mysuckypassword'
          admin:
            passwd_scheme: ssha
            passwd: '8D0R+itvu3Z3pR9TobvSaIy481w='
    - fqdn: public.authrealm.local
      http:
        port: 80
        enabled: true
        force_https: true
      https:
        port: 443
        root: /var/www/html
        enabled: true
        cert_dir: /etc/ssl/certs
        cert_name: public-authrealm.crt
        key_dir: /etc/ssl/private
        key_name: public-authrealm.key
      auth_basic:
        realm: 'Private area'
        uri: /private/
