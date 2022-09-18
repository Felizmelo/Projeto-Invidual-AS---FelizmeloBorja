#!/bin/bash

# Administração de Sistemas 2019/2020     
#Felizmelo pereira Borja-16709                        
# Projeto Individual                                
# "Question 6 - Delete Forward & Reverse Zone and VirtualHost" 	  
#---------------------------------------------------

# Variables
http_userdir_conf=/etc/httpd/conf.d/userdir.conf
zona_master=/etc/named.conf
var_named=/var/named/
domain_dir=/dominios/
domain_name=$1 # Este domínio aceita apenas um argumento
reverse_ip_address=$1 # Este reverse_ip_address aceita apenas um argumento

# Lista todos os dominios que ja foram criados 
lista_de_dominios_criados=$(grep '^zone' $zona_master | cut -d'"' -f2)

# https://unix.stackexchange.com/questions/119269/how-to-get-ip-address-using-shell-script
ip_add=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
#-----------------------------------------------------------------------------------------------------------------------

echo ""
echo "Lista de todos os domínios já criados Lista de todos os domínios já criados:"
echo "$lista_de_dominios_criados"
echo ""

# Esta função removerá o arquivo DNS Forward Zone do named.conf e excluirá o arquivo da zona armazenado no diretório / var / named
function remove_forward(){
	# https://serverfault.com/questions/909226/delete-a-zone-from-named-conf-with-shell-script
	sed -nie "/\"$domain_name\"/,/^\};"'$/d;p;' $zona_master
	rm ${var_named}/${domain_name}.hosts
}

# Esta função irá remover VirtualHost
function remove_virtualhost(){
	# https://serverfault.com/questions/909226/delete-a-zone-from-named-conf-with-shell-script
	sed '/<VirtualHost *:80/,/<\/VirtualHost>/d' $http_userdir_conf
	sed -nie "/\"$domain_name\"/,/^\};"'$/d;p;' $zona_master
	rm ${var_named}/${domain_name}.hosts
	rm -rf ${domain_dir}${domain_name} 
}

# Esta função removerá o arquivo da zona de reserva de DNS do named.conf e excluirá o arquivo da zona reversa armazenado no diretório / var / named
function remove_reserve(){
	# https://serverfault.com/questions/909226/delete-a-zone-from-named-conf-with-shell-script
	sed -nie "/\"$reverse\"/,/^\};"'$/d;p;' $zona_master
	rm ${var_named}/${reverse}.hosts
}


# Esta função verifica a condição se o usuário deseja remover Forward Zone
function escolher_forward() {
	read -p "Por favor, insira um domínio ForwardZone que você deseja remover: " domain_name
	read -p "$domain_name vai ser removido de $zona_master, enter (y/n): " confirm
	echo ""
	if [ $confirm == "y" ]; then
		remove_forward
		echo "$domain_name foi removido com sucesso de $zona_master"
		echo ""
	else
		echo "Você pressionou \" n \", nenhuma ação será realizada"
		exit
	fi
}

# Esta função verifica a condição se o usuário deseja remover Forward Zone
function escolher_reverse() {
	read -p "Por favor, insira um endereço IP que você deseja remover: " ip_add
	reverse=$(echo $ip_address | awk 'BEGIN{FS="."}{print $3"."$2"."$1".in-addr.arpa"}')
	read -p "$reverse vai ser removido de $zona_master, enter (y/n): " confirm
	echo ""
	if [ $confirm == "y" ]; then
		remove_reserve
		echo "$reverse_ip_address foi removido com sucesso de $zona_master"
		echo ""
	else
		echo "Você pressionou \"n\", nenhuma ação será realizada"
		exit
	fi
}

# Esta função verifica a condição se o usuário deseja remover VirtualHost 
function escolher_virtualhost() {
	read -p "Por favor, insira um domínio VirtualHost que você deseja remover: " domain_name
	read -p "VirtualHost será removido, por favor entre (y/n): " confirm
	echo ""
	if [ $confirm == "y" ]; then
		remove_virtualhost
		echo "VirtualHost foi removido com sucesso"
		echo ""
	else
		echo "Você pressionou \"n\", nenhuma ação será realizada"
		exit
	fi
}



#------------------------------------------------------------------------------------------------------
# Selecione a opção que deseja executar
function escolher_opcao(){
	echo "Por favor, insira uma das opções abaixo: "
	options=(RemoverForward RemoverReverse RemoverVirtualHost)
	select type in ${options[@]}
	do
		if [ $type == RemoverForward ]; then
			escolher_forward
		    echo "Reiniciando o serviço dns em 3 segundos"
			sleep 3
			systemctl restart named 
		    break;
		elif [ $type == RemoverReverse ]; then
			escolher_reverse
		   	echo "Reiniciando o serviço dns em 3 segundos"
			sleep 3
			systemctl restart named 
		    break;
		elif [ $type == RemoverVirtualHost ]; then
			escolher_virtualhost
			echo "Reiniciando o serviço dns e http em 3 segundos"
			sleep 3
			systemctl restart named 
			systemctl restart httpd
		 else 
		      echo "Você escolhe outra opção, o programa será encerrado e nenhuma ação adicional será realizada"
		      echo ""
		      sleep 3
		      exit
		fi
	done
}

escolher_opcao
