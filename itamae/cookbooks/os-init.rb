
execute 'os init' do
    command <<'EOH'
echo 'Asia/Tokyo' |tee /etc/timezone
apt-get update
apt-get upgrade -y
EOH
    not_if 'cat /etc/timezone |grep Asia/Tokyo'
end
