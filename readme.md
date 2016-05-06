
### Vagrant + Debian + MySQL + nginx + PHP7

Base: Vagrant
OS : Debian/jessie64
DB: MysQL (Debian apt Latest)
Front: nginx (nginx.org Latest)
Back: PHP 7.0.6 (with phpenv, php-build)

***Usage:***
```
user@host:~$ git clone https://github.com/mkgask/vmynp706.git
user@host:~$ vagrant up
user@host:~$ itamae ssh -h 192.168.33.15 -u vagrant itamae/roles/server-setup.rb
```
