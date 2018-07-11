require 'serverspec'

set :backend, :exec

describe 'NGINX Package and Service' do

  describe package('nginx') do
    it { should be_installed }
  end

  describe service('nginx') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port('80') do
    it { should be_listening}
  end

  describe port('443') do
    it { should be_listening}
  end

end

describe 'NGINX Sites' do

  describe file('/etc/nginx/sites-enabled/localhost.local') do
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match /server_name localhost.local;\s*listen 80;\s*listen \[::\]:80;/ }
    its(:content) { should match /listen 443;\s*listen \[::\]:443;\s*server_name localhost.local;/ }
    its(:content) { should match /ssl_certificate .*localhost.local.crt/ }
    its(:content) { should match /ssl_certificate_key .*localhost.local.key/ }
    its(:content) { should match /^upstream tomcat {\s*server \[::\]:8080/ }
  end

  describe file('/etc/nginx/sites-enabled/sub.localhost.local') do
    its(:content) { should match /root \/var\/www\/html/  }
    its(:content) { should match /server_name sub.localhost.local/  }
    its(:content) { should match /location \/another\/ \{/ }
    its(:content) { should match /root \/var\/www\/another;/ }
    its(:content) { should match /location \/test\/ \{/ }
    its(:content) { should match /root \/tmp\/test;/ }
  end

  describe file('/etc/nginx/sites-enabled/authrealm.local') do
    its(:content) { should match /server_name authrealm.local/ }
    its(:content) { should match /auth_basic              "Password protected";/ }
    its(:content) { should match /auth_basic_user_file    \/etc\/nginx\/sites-auth-users\/authrealm.local;/ }
  end

  describe file('/etc/nginx/sites-auth-users/authrealm.local') do
    its(:content) { should match /^regular-guy:{PLAIN}mysuckypassword/ }
    its(:content) { should match /^admin:{SSHA}8D0R\+itvu3Z3pR9TobvSaIy481w=/ }
  end

  describe file('/etc/nginx/sites-enabled/public.authrealm.local') do
    its(:content) { should match /return 301 https:\/\// }
    its(:content) { should match /location \/private\/ {[^}]*auth_basic\s+"Private area";\s*auth_basic_user_file\s+\/etc\/nginx\/sites-auth-users\/public.authrealm.local/ }
  end

end

describe 'NGINX Configs' do
  describe file('/etc/nginx/nginx.conf'), :if => os[:family] == 'debian' do
    its(:content) { should match /^user daemon;/ }
    its(:content) { should match /client_max_body_size 100M;/ }
  end

  describe file('/etc/nginx/nginx.conf'), :if => os[:family] == 'redhat' do
    its(:content) { should match /^user daemon;/ }
    its(:content) { should match /include \/etc\/nginx\/sites-enabled\/\*;/ }
  end

  describe file('/etc/nginx/conf.d/test/client.conf') do
    its(:content) { should match /client_header_buffer_size    4k;/ }
    its(:content) { should match /large_client_header_buffers  8 8k;/ }
  end

  describe file('/etc/nginx/conf.d/test/proxy.conf') do
    its(:content) { should match /proxy_buffer_size            4k;/ }
    its(:content) { should match /proxy_set_header             Host             \$host;/ }
  end

  describe file('/etc/nginx/conf.d/test/upstream.conf') do
    its(:content) { should match /upstream middleware/ }
    its(:content) { should match /server middleware1.example.com;/ }
    its(:content) { should match /upstream backend/ }
    its(:content) { should match /ip_hash;/ }
    its(:content) { should match /server backend1.example.com;/ }
  end

  describe file('/etc/nginx/conf.d/acls/test-acl.conf') do
    its(:content) { should match /allow 192.168.99.1\/32;/ }
    its(:content) { should match /allow 192.168.99.2\/32;/ }
  end
end
