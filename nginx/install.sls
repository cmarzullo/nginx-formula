# -*- coding: utf-8 -*-
# vim: ft=sls
# How to install nginx
{%- from "nginx/map.jinja" import nginx with context %}

nginx_required_pkgs:
  pkg.installed:
    - pkgs: {{ nginx.required_pkgs }}
{%- if nginx.from_repo is defined %}
    - fromrepo: {{ nginx.from_repo }}
{%- endif %}
