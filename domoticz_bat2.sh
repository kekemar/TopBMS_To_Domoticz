#!/bin/bash

#Valeur à modifier
#--------------------------------
#Port batterie
port_tty=/dev/ttyV1
#IP Domoticz
IP_Domoticz=192.168.10.12
#IDX Domoticz
d_pack_current=2405					#Capteur Virtuel de type Ampere Monophasé
d_voltage=2408						#Capteur Virtuel Tension
d_remaining_capacity_p=2409			#Capteur Virtuel de type Pourcentage
d_remaining_capacity=2407			#Capteur Virtuel de type Custom Sensor. Nom de l'axe Ah
d_cycle_count=2406					#Capteur Virtuel de type Custom Sensor. Nom de l'axe ' ' (Espace)
#--------------------------------

while true
do
	# Définir la réponse de la batterie
    read -N150 response < $port_tty

	# Déterminer la charge/decharge de la batterie en Ampere
	pack_current=$(echo $response | cut -c 108-111)
	pack_current=$(printf "%04X\n" 0X$pack_current)
	pack_current=$(echo -e "\x${pack_current:2}\x${pack_current::2}" | od -A n -N2 -t dS)
	pack_current=$(echo "scale=2; $pack_current / 100" | bc)
	/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$d_pack_current&nvalue=0&svalue=$pack_current" > /dev/null

	# Déterminer la tension de la batterie
	voltage=$(echo $response | cut -c 112-115)
	voltage=$(echo "ibase=16; $voltage" | bc)
	voltage=$(echo "scale=2; $voltage / 100" | bc)
	/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$d_voltage&nvalue=0&svalue=$voltage" > /dev/null

	# Déterminer la capacité restante en pourcentage
	remaining_capacity_p=$(echo $response | cut -c 130-131)
	remaining_capacity_p=$(echo "ibase=16; $remaining_capacity_p" | bc)
	/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$d_remaining_capacity_p&nvalue=0&svalue=$remaining_capacity_p" > /dev/null

	# Déterminer la capacité restante
	remaining_capacity=$(echo $response | cut -c 116-119)
	remaining_capacity=$(echo "ibase=16; $remaining_capacity" | bc)
	remaining_capacity=$(echo "scale=2; $remaining_capacity/100" | bc)
	/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$d_remaining_capacity&nvalue=0&svalue=$remaining_capacity" > /dev/null

	# Déterminer le nombre de cycles de charge/décharge
	cycle_count=$(echo $response | cut -c 126-129)
	cycle_count=$(echo "ibase=16; $cycle_count" | bc)
	/usr/bin/curl --silent "http://$IP_Domoticz:8080/json.htm?type=command&param=udevice&idx=$d_cycle_count&nvalue=0&svalue=$cycle_count" > /dev/null

done
