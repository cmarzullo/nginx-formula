# -*- coding: utf-8 -*-
# vim: ft=sls
# How to configure nginx
{%- from "nginx/map.jinja" import nginx with context %}

nginx_config:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: {{ nginx.conf_source }}
    - template: jinja
    - user: root
    - group : root
    - mode: 0644
    - runtime_user: {{ nginx.service.user }}

# Process /etc/nginx/conf.d/* file generation
{% if nginx.confd is defined %}
{% for confd_file, confd_config in nginx.confd.iteritems() %}
nginx_config_d_{{ confd_file }}:
  file.managed:
    - name: '/etc/nginx/conf.d/{{ confd_file }}'
    - source: {{ confd_config.source }}
    - user: root
    - group : root
    - mode: 0644
    - template: jinja
    - makedirs: true
    - config: {{ confd_config | yaml}}
    - watch_in:
      - service: nginx_service
{% endfor %}
{% endif %}

{% if nginx.sites is defined %}
nginx_site_config_dir:
  file.directory:
  - name: /etc/nginx/sites-enabled
  - user: root
  - group: root
  - mode: 0755

  {% for site in nginx.sites %}
  {% set source = site.get('source', 'salt://nginx/files/site_conf.j2') %}
nginx_site_config_{{ site.fqdn }}:
  file.managed:
    - name: /etc/nginx/sites-enabled/{{ site.fqdn }}
    - source: {{ source }}
    - user: root
    - group : root
    - mode: 0644
    - template: jinja
    - site: {{ site | yaml }}
    {% if site.https is defined -%}
      {%- set manage_ssl_certificate   = site.https.get('manage_cert', True)                   -%}
      {%- set ssl_certificate_name     = site.https.get('cert_name', site.fqdn + '.crt')       -%}
      {%- set ssl_certificate_key_name = site.https.get('key_name', site.fqdn + '.key')        -%}
      {%- set ssl_certificate          = site.https.cert_dir + '/' + ssl_certificate_name      -%}
      {%- set ssl_certificate_key      = site.https.key_dir  + '/' + ssl_certificate_key_name  -%}
    - ssl_certificate:     {{ ssl_certificate }}
    - ssl_certificate_key: {{ ssl_certificate_key }}
    {%- endif %}
    {% if site.auth_basic is defined -%}
      {%- set auth_basic_realm = site.auth_basic.get('realm', 'Authorized access only') -%}
      {%- set auth_basic_uri   = site.auth_basic.get('uri', '/')                        -%}
      {%- set auth_basic_users = site.auth_basic.get('users', {})                       -%}
      {%- set auth_basic_file  = '/etc/nginx/sites-auth-users/' + site.fqdn             -%}
    - auth_basic:
        realm: {{ auth_basic_realm }}
        file:  {{ auth_basic_file  }}
        uri:   {{ auth_basic_uri   }}

nginx_site_{{ site.fqdn }}_auth_user_file:
  file.managed:
    - name: {{ auth_basic_file }}
    - source: salt://nginx/files/site_auth_users.j2
    - user: {{ nginx.service.user }}
    - group: root
    - mode: 0600
    - makedirs: True
    - template: jinja
    - users: {{ auth_basic_users }}
    {%- endif %}

    {% if site.http is defined and site.http.root is defined %}
nginx_site_{{ site.fqdn }}_http_root:
  file.directory:
    - name: {{ site.http.root }}
    - user:  {{ nginx.service.user }}
      {%- if site.http.root_group is defined %}
    - group: {{ site.http.root_group }}
      {%- endif %}
    - mode: 0700
    - makedirs: True
    {% endif %}

    {% if site.https is defined %}
      {% if site.https.root is defined %}
nginx_site_{{ site.fqdn }}_https_root:
  file.directory:
    - name: {{ site.https.root }}
    - user: {{ nginx.service.user }}
      {%- if site.https.root_group is defined %}
    - group: {{ site.https.root_group }}
      {%- endif %}
    - mode: 0700
    - makedirs: True
      {% endif %}

      {% if manage_ssl_certificate %}
nginx_site_{{ site.fqdn }}_ssl_cert:
  file.managed:
    - name: {{ ssl_certificate }}
    - source: salt://nginx/files/{{ ssl_certificate_name }}
    - user: root
    - group: root
    - mode: 0644

nginx_site_{{ site.fqdn }}_ssl_key:
  file.managed:
    - name: {{ ssl_certificate_key }}
    - source: salt://nginx/files/{{ ssl_certificate_key_name }}
    - user: root
    - group: root
    - mode: 0600
      {% endif %}
    {% endif %}

  {% endfor %}
{% endif %}
