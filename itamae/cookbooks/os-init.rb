
execute 'os init' do
    command <<'EOH'
timedatectl set-timezone Asia/Tokyo
apt-get update
apt-get upgrade -y
EOH
    not_if 'timedatectl status |grep Asia/Tokyo'
end
