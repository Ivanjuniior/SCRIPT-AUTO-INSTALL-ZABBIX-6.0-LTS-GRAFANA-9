# SCRIPT-AUTO-INSTALL-ZABBIX-6.0-LTS
SCRIPT PARA INSTALAÇÃO DO ZABBIX 6.0-LTS

esse script foi testado usando a DISTRO Debian GNU/Linux 11 (Bulsey) e a versão do zabbix 6.0-LTS.

no script esta incluso os seguintes pacotes e dependencias:
  - NGINX
  - PostgreSQL
  - PHP 7.4
  - SNMP
 
Antes de executar o script, algumas informações devem ser alteradas, para o funcioanamento correto do mesmo.

## Banco de Dados

a linha : sudo -u postgres psql -c "create user zabbix with encrypted password ‘zabbix’” 2>/dev/null
contem o usuario e senha do banco, altere aqui para o de sua preferência.
a linha : sudo -u postgres createdb -O zabbix -E Unicode -T template0 zabbix 2>/dev/null
contem o banco, e aqui você colocará um nome de sua preferência.

## PHP

a linha : echo php_value[date.timezone] = America/Bahia | tee -a /etc/zabbix/php-fpm.conf >/dev/null
contem o timezone, altere para aqui.

## ZABBIX

o zabbix para uma boa performance deve ser alterado alguns parâmentros, no script foi deixado umas regras predefinidas, levando em consideração que você tenha criado um servidor com no minimo 4GB de Memoria RAM. Não irei me abordar aqui para que serve cada modulo da configurção, mas direi que obrigatoriamente que DBHost, DBName, DBUser, DBPassword é extremamente importante para o funcionamento do zabbix-server.

  - DBHost
  - DBName
  - DBUser
  - DBPassword
  - StartPollers
  - StartIPMIPollers
  - StartPollersUnreachable
  - StartTrappers
  - StartPingers
  - StartDiscoverers
  - HousekeepingFrequency
  - CacheSize
  - StartDBSyncers
  - HistoryCacheSize
  - TrendCacheSize
  - ValueCacheSize
 
Ao concluir a instalação do script, é só chamar o endereço IP da maquino no navegador e concluir os Passos por lá !
