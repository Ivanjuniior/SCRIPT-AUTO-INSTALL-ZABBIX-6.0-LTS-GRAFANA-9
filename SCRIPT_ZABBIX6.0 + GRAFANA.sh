#!/bin/bash

#===============================================================>
#=====>		NAME:............:	auto_install_zabbix_6.0.sh      #
#=====>		VERSION:.........:	2.0                             #
#=====>		DESCRIPTION:.....:	Auto Instalação Zabbix 6.0-LTS  #
#=====>		CREATE DATE:.....:	06/06/2022                      #
#=====>		UPDATE DATE:.....:	7/01/2023                       #
#=====>		WRITTEN BY:......:	Ivan da Silva Bispo Junior      #
#=====>		E-MAIL:..........:	contato#ivanjr.eti.br           #
#=====>		DISTRO:..........:	Debian GNU/Linux 11 (Bullseye)  #
#===============================================================>
echo -e "\033[32;1;5m========Informe os dados abaixo========"
echo""
read -p "Digite o nome do usuário do banco de dados: " NOME_USUARIO
read -p "Digite a senha do usuário do banco de dados: " SENHA_USUARIO
read -p "Digite o nome do banco de dados: " NOME_BANCO
read -p "digite o ip do servidor: " IP

clear
echo -e "\033[32;1;5mAtualizando o sistema..."
sleep 3
apt-get update && apt-get upgrade -y
clear
echo -e "\033[32;1;5mInstalando o pacote sudo..."
sleep 3
apt-get -y install sudo
clear
NGINX=/etc/nginx/
if [ -d "$NGINX" ]; then
    echo ""
else
    echo -e "\033[32;1;5mInstalando o pacote nginx..."
    sleep 3
    apt-get -y install nginx
    sed -i 's/#server_tokens/server_tokens/' /etc/nginx/nginx.conf
    systemctl restart nginx
fi
clear
POSTGRESQL=/etc/postgresql/
if [ -d "$POSTGRESQL" ]; then
    echo ""
else
    echo -e "\033[32;1;5mInstalando o pacote postgresql..."
    sleep 3
    apt-get -y install postgresql
fi
clear
PHP=/etc/php/
if [ -d "$PHP" ]; then
    echo ""
else
    echo -e "\033[32;1;5mInstalando o pacote php..."
    sleep 3
    apt-get -y install php php-{fpm,cli,mysql,pear,gd,gmp,bcmath,mbstring,curl,xml,zip,json,pgsql}
fi
clear
echo -e "\033[32;1;5mInstalando pacotes necessarios..."
sleep 3
apt-get -y install snmpd snmp snmptrapd libsnmp-base libsnmp-dev

apt-get -y install vim bash-completion fzf grc

apt-get -y install gnupg2 apt-transport-https software-properties-common wget

apt-get -y install curl zip unzip
clear
echo -e "\033[32;1;5madicionando o repositório do zabbix..."
cd /tmp && wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-1+debian11_all.deb
dpkg -i zabbix-release_6.0-1+debian11_all.deb
sleep 3
clear
apt-get update
clear
ZABBIX=/etc/zabbix/
if [ -d "$ZABBIX" ]; then
    echo ""
else
    echo -e "\033[32;1;5mInstalando o pacote zabbix..."
    sleep 3
    apt-get -y install zabbix-server-pgsql zabbix-frontend-php php7.4-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent
fi

clear
echo -e "\033[32;1;5mCriando o banco de dados e o usuário do banco de dados..."
sleep 3
sudo sed -i "s/ident/md5/g" /etc/postgresql/13/main/pg_hba.conf
su postgres -c "psql -c \"CREATE USER $NOME_USUARIO WITH PASSWORD '$SENHA_USUARIO';\""
su postgres -c "psql -c \"CREATE DATABASE $NOME_BANCO WITH OWNER $NOME_USUARIO;\""
su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $NOME_BANCO TO $NOME_USUARIO;\""
clear
echo -e "\033[32;1;5mBanco de dados criado com sucesso!"
sleep 3
echo -e "\033[32;1;5mImportando o banco de dados..."
sleep 3
zcat /usr/share/doc/zabbix-sql-scripts/postgresql/schema.sql.gz | sudo -u $NOME_USUARIO psql $NOME_BANCO
clear
echo -e "\033[32;1;5mBanco de dados importado com sucesso!"
echo -e "\033[32;1;5mConfigurando data e hora..."
sleep 3
echo php_value[date.timezone] = America/Bahia | tee -a /etc/zabbix/php-fpm.conf >/dev/null

echo LANG=en_US.UTF-8 | tee -a /etc/default/locale >/dev/null
clear
echo -e "\033[32;1;5mConfigurando o zabbix-server..."
sleep 3
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
clear
echo -e "\033[32;1;5mCriando o arquivo de configuração no nginx..."
sleep 3
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/conf.d/zabbix.conf
sudo ln -s /etc/zabbix/nginx.conf /etc/nginx/sites-available/default
sudo ln -s /etc/zabbix/nginx.conf /etc/nginx/sites-enabled/default
clear
echo -e "\033[32;1;5mRestartando os serviços..."
sleep 3
sudo systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm postgresql@13-main
echo "Habilitando os serviços..."
sudo systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm postgresql@13-main
clear
echo -e "\033[32;1;5mInstalação finalizada com sucesso!"
echo "Acesse o endereço http://$IP e faça o login com as credenciais abaixo:"
echo "Usuário: Admin"
echo "Senha: zabbix"
#===============> GRAFANA <================#
read -p "Deseja instalar o Grafana? [S/N] " -n 1 -r
cd /tmp/
if [[ $REPLY =~ ^[Ss]$ ]]
then
  echo ""
  echo -e "\033[32;1;5mInstalando o Grafana..."
  sleep 3
  wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
  echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list
  apt-get update
  apt-get -y install grafana
  grafana-cli plugins install alexanderzobnin-zabbix-app
  grafana-cli plugins update-all
  systemctl daemon-reload
  systemctl enable grafana-server
  systemctl start grafana-server
  echo -e "\033[32;1;5mGrafana instalado com sucesso!"
  echo "Acesse o endereço http://$IP:3000 e faça o login com as credenciais abaixo:"
  echo "Usuário: admin"
  echo "Senha: admin"
  echo "Após o login, clique em 'Add data source' e selecione o Zabbix"
  echo "Em 'URL' digite http://localhost/zabbix e clique em 'Save & Test'"
  echo "Agora clique em 'Create' e selecione 'Dashboard'"
  echo "Clique em 'Add new panel' e selecione 'Graph'"
  echo "Clique em 'Edit' e selecione 'Metrics'"
  echo "Clique em 'Add query' e selecione 'Zabbix'"
  echo "Em 'Host group' selecione o grupo que deseja monitorar"
  echo "Em 'Application' selecione a aplicação que deseja monitorar"
  echo "Em 'Item' selecione o item que deseja monitorar"
  echo "Clique em 'Save' e pronto!"
  echo "Agora é só criar um dashboard e adicionar os painéis que desejar!"
  echo "Para mais informações, acesse https://grafana.com/docs/grafana/latest/datasources/zabbix/"
else
  echo ""
  echo -e "\033[32;1;5mInstalação finalizada com sucesso!"
  echo "Acesse o endereço http://$IP e faça o login com as credenciais abaixo:"
  echo "Usuário: Admin"
  echo "Senha: zabbix"
fi
#===============> TELEGRAM <================#
read -p "Deseja instalar o Telegram? [S/N] " -n 1 -r
if [[ $REPLY =~ ^[Ss]$ ]]
then
  echo ""
  read -p "Digite o ID do chat do telegram: " ID_TELEGRAM
  read -p "Digite o Token do telegram: " TK_TELEGRAM
  clear
  echo -e "\033[32;1;5mInstalando o Telegram..."
  sleep 3
mkdir /etc/backups/
wget https://raw.githubusercontent.com/remontti/telegramBotShell/master/telegram -O /bin/telegram
chmod +x /bin/telegram
clear
echo -e "\033[32;1;5mInstalação finalizada com sucesso!"
sed -i 's/ID_TELEGRAM="000000000"/ID_TELEGRAM="'${ID_TELEGRAM}'"/' /bin/telegram
sed -i 's/ID_CHAT="000000000"/ID_CHAT="'${ID_CHAT}'"/' /bin/telegram
sed -i 's/TOKEN="000000000:0000000000000-0000000000000000000000000000000"/TOKEN="'${TK}'"/' /bin/telegram
/bin/telegram -m "${ID_TELEGRAM}" " Instalação do zabbix + grafana foi efetuada com sucesso…" &>/dev/null
else
  echo ""
  echo -e "\033[32;1;5mInstalação finalizada com sucesso!"
  echo "Acesse o endereço http://$IP e faça o login com as credenciais abaixo:"
  echo "Usuário: Admin"
  echo "Senha: zabbix"
fi
echo-e "\033[32;1;5mDeixe uma estrela no repositório do github:Ivanjuniior"
echo -e "\033[32;1;5mDesenvolvido por: Ivan Junior"
echo -e "\033[32;1;5mDoaçoes via pix: contato@ivanjr.eti.br"
echo -e "\033[32;1;5mDoaçoes via paypal: https://www.paypal.com/donate?hosted_button_id=ZQZ2Z2Z2Z2Z2Z"
echo -e "\033[32;1;5mDoaçoes via picpay: https://app.picpay.com/user/ivanjunior"
echo -e "\033[32;1;5mDoaçoes via pagseguro: https://pag.ae/7WZ2Z2Z2Z2Z2Z"