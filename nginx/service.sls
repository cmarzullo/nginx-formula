# -*- coding: utf-8 -*-
# vim: ft=sls
# Manage service for service nginx
{%- from "nginx/map.jinja" import nginx with context %}

nginx_service:
  service.{{ nginx.service.state }}:
    - name: {{ nginx.service.name }}
    - enable: {{ nginx.service.enable }}
    - watch:
      - file: nginx_config
{%- if nginx.sites is defined %}
  {%- for site in nginx.sites %}
      - file: nginx_site_config_{{ site.fqdn }}
  {%- endfor %}
{%- endif %}
