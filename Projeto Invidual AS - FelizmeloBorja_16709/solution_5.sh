#!/bin/bash

# Administração de Sistemas 2020/2021       
#---------------------------------------------------

# Variables
zone_master_conf=/etc/named.conf 
var_named_dir=/var/named/
domain_name=$1
ip_address=$1

# https://unix.stackexchange.com/questions/8518/how-to-get-my-own-ip-address-and-save-it-to-a-variable-in-a-shell-script
ip4_address="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"

# Liste todos os nomes de domínio criados
list_of_created_domain=$(grep '^zone' $zone_master_conf | cut -d'"' -f2)
#--------------------------------------------------------------------------------------------------------------
echo ""
echo "Lista de todos os domínios que já foram criados, escolha OUTRO nome de domínio para evitar erros:"
echo "$list_of_created_domain"
echo ""

# Entrada para IP e Domínio
read -p "Enter a Domain (eg.: example.com): " domain_name
echo ""
read -p "Please, enter an IP address: " ip_address
echo ""


# Endereço IP reverso, começando do último para o primeiro
# https://itectec.com/unixlinux/shell-how-to-read-an-ip-address-backwards/
reverse=$(echo $ip_address | awk 'BEGIN{FS="."}{print $3"."$2"."$1".in-addr.arpa"}')
reverse_last=$(echo $ip_address | awk 'BEGIN{FS="."}{print $4}')

echo "$ip_address => $reverse"
echo "$ip_address => $reverse_last"
echo ""

# Esta função adiciona uma zona reversa ao arquivo named.conf
function create_reverse_zone() {
    echo "zone \"$reverse\" IN {
            type master;
            file \"/var/named/${reverse}.hosts\";
        };
    " >> $zone_master_conf
}

# Esta função cria um arquivo de zona reversa em /var/named/ directory
function create_reverse_hosts_file() {

echo "
\$ttl 38400
@	IN  SOA	dns.$domain_name.	mail.$domain_name.(
		1165190726; serial
		10800; refresh
		3600; retry
		604800; expire
		38400; minimum
		) 
	IN    NS    dns.$domain_name.
$reverse_last	IN    PTR 	$domain_name." > ${var_named_dir}${reverse}.hosts
}


# Crie uma zona reversa:
function create_reverse_dns(){
	while true; 
	do
	    read -p "Zona reversa para $domain_name será criado, deseja continuar? Por favor, insira (y/n): " answer
	    case $answer in
	        [Yy]* ) 
				create_reverse_zone
				create_reverse_hosts_file
				echo ""
				echo "Você criou uma zona reversa para \"$domain_name\" com endereço IP reverso: \"${ip_address}\""
				echo ""
				# Reinicie o serviço DNS
				echo "Reiniciando o serviço dns em 3 segundos"
				sleep 3
				systemctl restart named
				break;
				;;
	        [Nn]* )
				echo "Nenhuma zona reversa foi criada, saindo em 3 segundos"
				sleep 3
				exit
				break;
				;;
	    esac
	done
}

create_reverse_dns
