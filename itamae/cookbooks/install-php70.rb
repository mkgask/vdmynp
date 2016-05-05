
%w(git autoconf automake libtool make wget bison flex re2c libjpeg-dev libpng12-dev libxml2-dev libbz2-dev libmcrypt-dev libssl-dev libcurl4-openssl-dev libreadline6-dev libtidy-dev libxslt-dev pkg-config).each do |pkg|
    package pkg
end

execute 'install phpenv' do
    command <<'EOH'
cd /tmp
wget -O phpenv.tar.gz https://github.com/madumlao/phpenv/archive/master.tar.gz
tar zxvf phpenv.tar.gz
mv phpenv-master /home/vagrant/.phpenv
echo 'export PATH="/home/vagrant/.phpenv/bin:$PATH"' |tee -a /home/vagrant/.bashrc
echo 'eval "$(phpenv init -)"' |tee -a /home/vagrant/.bashrc
EOH
    user 'vagrant'
    not_if 'ls -la /home/vagrant |grep .phpenv'
end

execute 'instlal php-build' do
    command <<'EOH'
cd /tmp
wget -O php-build.tar.gz https://github.com/php-build/php-build/archive/master.tar.gz
tar zxvf php-build.tar.gz
mkdir -p /home/vagrant/.phpenv/plugins
mv php-build-master /home/vagrant/.phpenv/plugins/php-build
EOH
    user 'vagrant'
    not_if 'ls -la /home/vagrant/.phpenv/plugins |grep php-build'
end

execute 'build php70' do
    command <<'EOH'
cd ~
export PATH="/home/vagrant/.phpenv/bin:$PATH"; eval "$(phpenv init -)"; phpenv install 7.0.6
export PATH="/home/vagrant/.phpenv/bin:$PATH"; eval "$(phpenv init -)"; phpenv global 7.0.6
EOH
    user 'vagrant'
    not_if 'ls -la /home/vagrant/.phpenv/versions |grep 7.0.6'
end

execute 'php-fpm settings' do
    command <<'EOH'
cd ~
cp /home/vagrant/.phpenv/versions/7.0.6/etc/php-fpm.conf.default /home/vagrant/.phpenv/versions/7.0.6/etc/php-fpm.conf
sed -i 's%;pid = run/php-fpm.pid%pid = run/php-fpm.pid%' /home/vagrant/.phpenv/versions/7.0.6/etc/php-fpm.conf
sed -i 's%;daemonize = yes%daemonize = yes%' /home/vagrant/.phpenv/versions/7.0.6/etc/php-fpm.conf
cp /home/vagrant/.phpenv/versions/7.0.6/etc/php-fpm.d/www.conf.default /home/vagrant/.phpenv/versions/7.0.6/etc/php-fpm.d/www.conf
sed -i 's%user = nobody%user = nginx%' /home/vagrant/.phpenv/versions/7.0.6/etc/php-fpm.d/www.conf
sed -i 's%group = nobody%group = nginx%' /home/vagrant/.phpenv/versions/7.0.6/etc/php-fpm.d/www.conf

cp /tmp/php-build/source/7.0.6/sapi/fpm/php-fpm.service /tmp/php-build/source/7.0.6/sapi/fpm/php-fpm.service.edit
sed -i 's%${prefix}%/home/vagrant/.phpenv/versions/7.0.6%' /tmp/php-build/source/7.0.6/sapi/fpm/php-fpm.service.edit
sed -i 's%${exec_prefix}%/home/vagrant/.phpenv/versions/7.0.6%' /tmp/php-build/source/7.0.6/sapi/fpm/php-fpm.service.edit
sed -i 's%--nodaemonize%%' /tmp/php-build/source/7.0.6/sapi/fpm/php-fpm.service.edit
cp /tmp/php-build/source/7.0.6/sapi/fpm/php-fpm.service.edit /etc/systemd/system/php-fpm.service
echo '<?php phpinfo();' | tee /usr/share/nginx/html/phpinfo.php
EOH
    not_if 'ls -la /etc/systemd/system |grep php-fpm.service'
end

service 'php-fpm' do
    action :start
end
