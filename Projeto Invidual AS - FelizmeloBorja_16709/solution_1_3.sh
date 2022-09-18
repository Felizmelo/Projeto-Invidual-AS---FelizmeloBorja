#!/bin/bash
#Felizmelo pereira Borja-16709
# Projeto: Administração de Sistemas 2020/2021


# Variaveis globais 
zona_master=/etc/named.conf 
var_named=/var/named/
http_userdir_conf=/etc/httpd/conf.d/userdir.conf
domain_dir=/dominios/
html_file=index.html


# https://unix.stackexchange.com/questions/119269/how-to-get-ip-address-using-shell-script
# busca o endereco IP da maquina de forma automatica
ip_add=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

# Esta variavel aceita apenas um argumento
dominio=$1
port=$1

# Lista todos os dominios que ja foram criados 
lista_de_dominios_criados=$(grep '^zone' $zona_master | cut -d'"' -f2)
echo ""
echo "List of all domains that has already been created Lista de todos os domínios já criados: "
echo "$lista_de_dominios_criados"
echo ""


# Adiciona a zona forward na (zona_master=/etc/named.conf)
function create_forward_zone(){

	# Open access to the nameserver to other IP addresses by adding "any" to the following lines.
	# https://stackoverflow.com/questions/11245144/replace-whole-line-containing-a-string-using-sed/11245501
	sed -i '/listen-on port 53 { 127.0.0.1; };/c\listen-on port 53 { 127.0.0.1; any; };' $zona_master
	sed -i '/allow-query     { localhost; };/c\allow-query     { localhost; any; };' $zona_master

	echo "zone \"$dominio\" IN {
		type master;
		file \"${var_named}${dominio}.hosts\";
	};
	" >> $zona_master
}

# Cria o ficheiro de dominio de zona forward na diretoria /var/named/ 
function create_domain_hosts_file(){

echo "
\$ttl 38400
@	IN  SOA	dns.$dominio.	mail.$dominio. (
			1165190726; serial
			10800; refresh
			3600; retry
			604800; expire
			38400; minimum
			)
	IN 	NS	dns.$dominio.
	IN 	A 	$ip_add
dns IN 	A 	$ip_add
www	IN 	A 	$ip_add
" > ${var_named}${dominio}.hosts
}


# This function creates VirtualHost structure into http_userdir_conf file, also creates html file into /var/named/dominios/ directory
function create_virtualhost_file(){

echo "
<VirtualHost *:80>
ServerName www.${dominio}
ServerAlias ${dominio}
DocumentRoot \"${domain_dir}${dominio}\"
<Directory \"${domain_dir}${dominio}\">  
	Options Indexes FollowSymLinks
	AllowOverride All
	Order allow,deny
	Allow from all
	Require method GET POST OPTIONS
</Directory>
</VirtualHost>
" >> $ 

mkdir -p ${domain_dir}${dominio}
echo "
<html>
	<body>
		<h1>Bem vindo ao domínio: $dominio</h1>
	</body>
</html>
"> ${domain_dir}${dominio}/${html_file}
chmod 755 ${domain_dir}${dominio} -R
}


# Permite o utilizador criar dominio de forma automatica
function create_dns(){
	while true; 
	do
	    read -p "Deseja criar um domínio? Por favor, insira (y/n): " yn
	    case $yn in
	        [Yy]* ) 
				read -p "Insira o nome do Domínio: " dominio 
				create_forward_zone
				create_domain_hosts_file
				echo "Domínio: $dominio criado"
				echo ""
				break;
				;;
	        [Nn]* )
				echo "Nenhum Domínio foi criado"
				echo ""
				exit
				break;
				;;
	    esac
	done
}


# Permite o utilizador criar dominio de forma automatica
function create_virtualhost(){
	while true; 
	do
	    read -p "Deseja criar um VirtualHost? Por favor, insira (y/n): " yn
	    case $yn in
	        [Yy]* ) 
				read -p "Insira o nome do Domínio VirtualHost que deseja criar: " dominio 
				create_forward_zone
				create_domain_hosts_file
				create_virtualhost_file
				echo ""
				echo "Domínio VirtualHost: $dominio criado"
				echo ""
				break;
				;;
	        [Nn]* )
				echo "Nenhum Domínio VirtualHost foi criado"
				echo ""
				exit
				break;
				;;
	    esac
	done
}


function execute_ponto1_ponto3(){
	echo "O utilizador pretende executar o PONTO_1_DNS ou PONTO_3_VH?"
	options=(PONTO_1_DNS PONTO_3_VH SAIR)
	select pontos in ${options[@]}
	do
		case $pontos in 
			PONTO_1_DNS)
				create_dns

				# Faz o restart do servico dns
				echo "Reiniciando o serviço DNS em 3 segundos"
				sleep 3
				systemctl restart named.service
				break;
				;;
			PONTO_3_VH)
				create_virtualhost

				# Restart the DNS and HTTP Apache services
				echo "Restarting the \"DNS and Apache\" services in 3 seconds"
				sleep 3
				systemctl restart named.service
				systemctl restart httpd.service
				systemctl enable httpd
				break;
				;;
			SAIR)
				echo"O utilizador pretendeu sair do programa..."
				exit
				break;
				;;
		esac
	done
}


execute_ponto1_ponto3




