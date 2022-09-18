#!/bin/bash

# Projeto: Administração de Sistemas 2020/2021     
#Felizmelo pereira Borja-16709

# Variaveis globais
var_named_dir=/var/named/
zone_master_conf=/etc/named.conf 
domain_name=$1
sub_domain_name=$1
ip_address_record=$1

# Liste todos os nomes de domínio criados
list_of_created_domain=$(grep '^zone' $zone_master_conf | cut -d'"' -f2)
#----------------------------------------------------------------------------------------------------


# Esta função grava novos registros do tipo A e MX no arquivo domain_name.hosts
function add_record() {

  echo "Para adicionar um registro A ou MX,"
  echo "insira um NOME DE DOMÍNIO dos domínios criados: "
  select domain_name in ${list_of_created_domain[@]}
  do
    break;
  done
  echo ""
  echo "$domain_name foi selecionado"
  echo ""

  echo "Agora, selecione o tipo de registro A ou MX: "
  options=(A MX)
  select type in ${options[@]}
  do
    if [ $type == A ]; then
      read -p "Insira um sub-domínio (Exemplo.: \"ftp\"): " sub_domain_name
      read -p "Insira um endereço IP (Exemplo.: \"127.0.0.1\"): " ip_address_record
      echo "Adicionando seu registro A ao arquivo... "
      echo "$sub_domain_name  IN  A   $ip_address_record" >> ${var_named_dir}${domain_name}.hosts
      echo "Reiniciando o serviço dns em 3 segundos"
      sleep 3
      systemctl restart named
      break;
    elif [ $type == MX ]; then
      read -p "Insira um FQDN (Exemplo.: \"ftp.lisboa.pt.\"): " fqdn
      read -p "Insira um número de prioridade(Exemplo.: \"10\"): " priority
      echo "Adicionando seu registro MX ao arquivo ..."
      echo "    IN  MX  $priority $fqdn" >> ${var_named_dir}${domain_name}.hosts
      echo "Reiniciando o serviço dns em 3 segundos"
      sleep 3
      systemctl restart named
      break;
  else 
      echo "Você escolhe outra opção, o programa será encerrado e nenhuma ação adicional será realizada"
      echo ""
      sleep 3
      exit
    fi
  done
}


#Função invocar:
add_record