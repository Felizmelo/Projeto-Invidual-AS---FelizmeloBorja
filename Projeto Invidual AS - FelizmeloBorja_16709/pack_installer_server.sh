#!/bin/bash

################################################################################
#                                                                              #
#                   Administração de Sistemas 2020/2021                        #
#                            Projeto Individual                                #
#                                                                              #
#                           Felizmelo Boeja 16709                              #
#                                                                              #
#							"Package Instalation"							   #
################################################################################

# This function install all the needed packages
function install_all_pack() {

	yum install setuptool -y
	yum install NetworkManager-tui -y 
	yum install system-config-securitylevel-tui -y
	yum install ntsysv -y
	yum install bind* -y 
	yum install httpd* -y
	yum install whois -y
	yum install samba4* -y
	yum install dhcp -y
	yum install ypserv -y
	yum install quota quota-devel -y
	yum install vsftpd -y
}

# Verifica se os pacotes já foram instalados, caso contrário, instale todos
if [ $install_all_pack==true ]; then
	echo ""
	echo "Todos os pacotes já foram instalados com sucesso"
	echo ""
	exit
else
	$install_all_pack
fi

echo ""
echo "INSTALAÇÃO COMPLETA DE SUCESSO!"
echo ""