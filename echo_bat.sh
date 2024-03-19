#!/bin/bash

while true
do
	# Définir la réponse de la batterie
    read -N150 response < /dev/ttyV0

	# Déterminer la charge/decharge de la batterie en Ampere
	pack_current=$(echo $response | cut -c 108-111)
	pack_current=$(printf "%04X\n" 0X$pack_current)
	pack_current=$(echo -e "\x${pack_current:2}\x${pack_current::2}" | od -A n -N2 -t dS)
	pack_current=$(echo "scale=2; $pack_current / 100" | bc)
	echo "Courant : $pack_current A"

	# Déterminer la tension de la batterie
	voltage=$(echo $response | cut -c 112-115)
	voltage=$(echo "ibase=16; $voltage" | bc)
	voltage=$(echo "scale=2; $voltage / 100" | bc)
	echo "Tension : $voltage V"

	# Déterminer la capacité restante en pourcentage
	remaining_capacity_p=$(echo $response | cut -c 130-131)
	remaining_capacity_p=$(echo "ibase=16; $remaining_capacity_p" | bc)
	echo "Capacité restante : $remaining_capacity_p %"

	# Déterminer la capacité restante
	remaining_capacity=$(echo $response | cut -c 116-119)
	remaining_capacity=$(echo "ibase=16; $remaining_capacity" | bc)
	remaining_capacity=$(echo "scale=2; $remaining_capacity/100" | bc)
	echo "Capacité restante : $remaining_capacity Ah"

	# Déterminer la capacité totale
	total_capacity=$(echo $response | cut -c 122-125)
	total_capacity=$(echo "ibase=16; $total_capacity" | bc)
	total_capacity=$(echo $total_capacity/100 | bc)
	echo "Capacité totale : $total_capacity Ah"

	# Déterminer le nombre de cycles de charge/décharge
	cycle_count=$(echo $response | cut -c 126-129)
	cycle_count=$(echo "ibase=16; $cycle_count" | bc)
	echo "Nombre de cycles : $cycle_count"

done
