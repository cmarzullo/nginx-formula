# -*- coding: utf-8 -*-
# vim: ft=sls
# Init nginx
{%- from "nginx/map.jinja" import nginx with context %}

{%- if nginx.enabled %}
include:
  - nginx.install
  - nginx.config
  - nginx.service
{%- else %}
'nginx-formula disabled':
  test.succeed_without_changes
{%- endif %}
