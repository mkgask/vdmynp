
%w(libpcre3-dev libcurl4-openssl-dev).each do |pkg|
    package pkg
end

execute 'install nginx' do
    command <<'EOH'
curl http://nginx.org/keys/nginx_signing.key | apt-key add -
echo 'deb http://nginx.org/packages/debian/ jessie nginx' |tee -a /etc/apt/sources.list.d/nginx.list
echo 'deb-src http://nginx.org/packages/debian/ jessie nginx' |tee -a /etc/apt/sources.list.d/nginx.list
apt-get update
EOH
    only_if 'systemctl status nginx |grep inactive'
end

%w(nginx).each do |pkg|
    package pkg
end

execute 'nginx settings' do
    command <<'EOH'
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.default
EOH
    not_if 'ls -la /etc/nginx/conf.d |grep default.conf.default'
end

remote_file '/etc/nginx/conf.d/default.conf' do
    source 'nginx/default.conf'
end
