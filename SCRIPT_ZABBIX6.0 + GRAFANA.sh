#!/bin/bash

#===============================================================>
#=====>		NAME:		auto_install_zabbix_6.0.sh
#=====>		VERSION:	1.0
#=====>		DESCRIPTION:	Auto Instalação Zabbix 6.0-LTS
#=====>		CREATE DATE:	06/06/2022
#=====>		UPDATE DATE:	26/12/2022
#=====>		WRITTEN BY:	Ivan da Silva Bispo Junior
#=====>		E-MAIL:		noc@jbits.com.br
#=====>		DISTRO:		Debian GNU/Linux 11 (Bullseye)
#===============================================================>
#====================>VARIAVEIS<================================>
IP=''
USER_DB=''
PASSWD_DB=''
DATABASE_DB=''
TK=''
ID_TELEGRAM='1131822803'
#====================>VARIAVEIS<================================>

#/////////////////////////////// >> INSTALL PROG. << \\\\\\\\\\\\\\\\\\\\\\\#

apt-get update && apt-get upgrade -y

apt-get -y install sudo

apt-get -y install nginx

sed -i 's/#server_tokens/server_tokens/' /etc/nginx/nginx.conf
systemctl restart nginx

apt-get -y install postgresql

apt-get -y install php php-{fpm,cli,mysql,pear,gd,gmp,bcmath,mbstring,curl,xml,zip,json,pgsql}

apt-get -y install snmpd snmp snmptrapd libsnmp-base libsnmp-dev

apt-get -y install vim bash-completion fzf grc

apt-get -y install gnupg2 apt-transport-https software-properties-common wget

apt-get -y install curl zip unzip

cd /tmp && wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-1+debian11_all.deb
dpkg -i zabbix-release_6.0-1+debian11_all.deb
apt-get update
apt-get -y install zabbix-server-pgsql zabbix-frontend-php php7.4-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent

#/////////////////////////////// >> END INSTALL PROG. << \\\\\\\\\\\\\\\\\\\\\\\#

sudo sed -i "s/ident/md5/g" /etc/postgresql/13/main/pg_hba.conf
sudo -u postgres psql -c "create user zabbix with encrypted password '12345678'" 2>/dev/null
sudo -u postgres createdb -O zabbix -E Unicode -T template0 zabbix 2>/dev/null

zcat /usr/share/doc/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

echo php_value[date.timezone] = America/Bahia | tee -a /etc/zabbix/php-fpm.conf >/dev/null

echo LANG=en_US.UTF-8 | tee -a /etc/default/locale >/dev/null

sudo sed -i "s/# DBHost=localhost/DBHost=localhost/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# DBName=zabbix/DBName=zabbix/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# DBPassword=/DBPassword=12345678/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# StartPollers=5/StartPollers=5/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# StartIPMIPollers=0/StartIPMIPollers=0/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# StartPollersUnreachable=1/StartPollersUnreachable=1/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# StartTrappers=5/StartTrappers=5/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# StartPingers=1/StartPingers=1/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# StartDiscoverers=1/StartDiscoverers=1/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# HousekeepingFrequency=1/HousekeepingFrequency=1/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# CacheSize=32M/CacheSize=32M/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# StartDBSyncers=4/StartDBSyncers=4/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# HistoryCacheSize=16M/HistoryCacheSize=16M/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# TrendCacheSize=4M/TrendCacheSize=4M/" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# ValueCacheSize=8M/ValueCacheSize=8M/" /etc/zabbix/zabbix_server.conf

sudo sed -i "s/#        listen          8080;/        listen          80;/" /etc/zabbix/nginx.conf
sudo sed -i "s/#        server_name     example.com;/        server_name     localhost;/" /etc/zabbix/nginx.conf

sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/conf.d/zabbix.conf
sudo ln -s /etc/zabbix/nginx.conf /etc/nginx/sites-available/default
sudo ln -s /etc/zabbix/nginx.conf /etc/nginx/sites-enabled/default

sudo systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm postgresql@13-main
sudo systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm postgresql@13-main

#========================================================================================

echo '' >> /etc/bash.bashrc
echo '# Autocompletar extra' >> /etc/bash.bashrc
echo 'if ! shopt -oq posix; then' >> /etc/bash.bashrc
echo '  if [ -f /usr/share/bash-completion/bash_completion ]; then' >> /etc/bash.bashrc
echo '    . /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc
echo '  elif [ -f /etc/bash_completion ]; then' >> /etc/bash.bashrc
echo '    . /etc/bash_completion' >> /etc/bash.bashrc
echo '  fi' >> /etc/bash.bashrc
echo 'fi' >> /etc/bash.bashrc
sed -i 's/"syntax on/syntax on/' /etc/vim/vimrc
sed -i 's/"set background=dark/set background=dark/' /etc/vim/vimrc
cat <<EOF >/root/.vimrc
set showmatch " Mostrar colchetes correspondentes
set ts=4 " Ajuste tab
set sts=4 " Ajuste tab
set sw=4 " Ajuste tab
set autoindent " Ajuste tab
set smartindent " Ajuste tab
set smarttab " Ajuste tab
set expandtab " Ajuste tab
"set number " Mostra numero da linhas
EOF
sed -i "s/# export LS_OPTIONS='--color=auto'/export LS_OPTIONS='--color=auto'/" /root/.bashrc
sed -i 's/# eval "`dircolors`"/eval "`dircolors`"/' /root/.bashrc
sed -i "s/# export LS_OPTIONS='--color=auto'/export LS_OPTIONS='--color=auto'/" /root/.bashrc
sed -i 's/# eval "`dircolors`"/eval "`dircolors`"/' /root/.bashrc
sed -i "s/# alias ls='ls \$LS_OPTIONS'/alias ls='ls \$LS_OPTIONS'/" /root/.bashrc
sed -i "s/# alias ll='ls \$LS_OPTIONS -l'/alias ll='ls \$LS_OPTIONS -l'/" /root/.bashrc
sed -i "s/# alias l='ls \$LS_OPTIONS -lA'/alias l='ls \$LS_OPTIONS -lha'/" /root/.bashrc
echo '# Para usar o fzf use: CTRL+R' >> ~/.bashrc
echo 'source /usr/share/doc/fzf/examples/key-bindings.bash' >> ~/.bashrc
echo "alias grep='grep --color'" >> /root/.bashrc
echo "alias egrep='egrep --color'" >> /root/.bashrc
echo "alias ip='ip -c'" >> /root/.bashrc
echo "alias diff='diff --color'" >> /root/.bashrc
echo "alias tail='grc tail'" >> /root/.bashrc
echo "alias ping='grc ping'" >> /root/.bashrc
echo "alias ps='grc ps'" >> /root/.bashrc
echo "PS1='\${debian_chroot:+(\$debian_chroot)}\[\033[01;31m\]\u\[\033[01;34m\]@\[\033[01;33m\]\h\[\033[01;34m\][\[\033[00m\]\[\033[01;37m\]\w\[\033[01;34m\]]\[\033[01;31m\]\\$\[\033[00m\] '" >> /root/.bashrc
echo "echo;echo 'U3Vwb3J0ZTogSkJpdHMgLSBOZXR3b3JrIFNlY3VyaXR5'|base64 --decode; echo;" >> /root/.bashrc
echo "echo 'Q29uc3VsdG9yOiBJdmFuIEp1bmlvcg=='|base64 --decode; echo;" >> /root/.bashrc
echo "echo 'V2Vic2l0ZTogaHR0cHM6Ly9qYml0cy5jb20uYnI='|base64 --decode; echo;" >> /root/.bashrc
echo "echo 'aG9yw6FyaW9zOiBTZWd1bmRhIGEgU2V4dGEgZMOhcyAwOTowMGhycyBhcyAxMjowMGhycyBlIDE0OjAwaHJzIMOgcyAxODowMGhycw=='|base64 --decode; echo;" >> /root/.bashrc

#========================================================================================
#===============> GRAFANA <================#
cd /tmp/
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list
apt-get update
apt-get -y install grafana
grafana-cli plugins install alexanderzobnin-zabbix-app
grafana-cli plugins update-all

systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
#===============> GRAFANA <================#
#========================================================================================
#===============> TELEGRAM <================#
mkdir /etc/backups/
wget https://raw.githubusercontent.com/remontti/telegramBotShell/master/telegram -O /bin/telegram
chmod +x /bin/telegram
sed -i 's/TOKEN="000000000:0000000000000-0000000000000000000000000000000"/TOKEN="'${TK}'"/' /bin/telegram
sed -i 's/ex: telegram -m "ID Chat" "Mensagem linha 1" "Mensagem linha 2" "Mensagem linha 3"/ex: telegram -m "1131822803" "Mensagem linha 1" "Mensagem linha 2" "Mensagem linha 3"/'  /bin/telegram
sed -i 's/ex: telegram -m "ID Usuário" "Mensagem linha 1" "Mensagem linha 2" "Mensagem linha 3"/ex: telegram -m "1131822803" "Mensagem linha 1" "Mensagem linha 2" "Mensagem linha 3"/' /bin/telegram
/bin/telegram -m "${ID_TELEGRAM}" " Instalação do zabbix + grafana foi efetuada com sucesso…" &>/dev/null
#===============> TELEGRAM <================#
