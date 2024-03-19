# TopBMS vers Domoticz
Script bash de récupération des données d'un BMS de batterie Lifepo4 chinoise achetée sur aliexpress et disposant d'un BMS TopBMS

![Image Domoticz](https://github.com/kekemar/TopBMS_To_Domoticz/blob/main/Domoticz.png)

# La Batterie 150Ah
Acheter sur [aliexpress](https://fr.aliexpress.com/item/1005005326189832.html?spm=a2g0o.order_list.order_list_main.47.21ef5e5bOCLO7d&gatewayAdapt=glo2fra)

Celle-ci dipose d'un BMS de la marque TOPBMS, modèle [BMS12S -16S 100A 150A 3.7V li-ion battery/3.2V lifepo4](https://www.cleverbms.com/picture/81.html)

![Image BMS](https://github.com/kekemar/TopBMS_To_Domoticz/blob/main/BMS/IMG20231018170736.jpg)

# Préambule
Je dispose de deux batteries idendiques que j'ai relié en RS232 à un boitier [USR-N540](https://www.pusr.com/products/4-port-serial-to-ip-converters-usr-n540.html)

La communication est de type 9600 N 8 1

Cela tourne sous un conteneur Proxmox, Debian 12

J'ai pleinement concience que la solution n'est pas optimale mais j'ai fait comme  j'ai pu car je n'ai trouvé aucun projet sur ce type de BMS et je n'ai trouvé qu'un logiciel Windows fonctionnant avec.

Je suis donc ouvert à toutes critiques dans la mesures où celle-ci seront constructrices.

# Recherche
Grace au logiciel Windows et au outils du boitier [USR-N540](https://www.pusr.com/products/4-port-serial-to-ip-converters-usr-n540.html) j'ai pu analyser les trames entrantes et sortantes afin d'en déduire le fonctionnement.

La documentation du protocole m'a un peu aidé mais je l'ai trouvé très flou

Exemple pour un envoi :
```
~21014642E00201FD34
```
La batterie répond :
```
~52014600408401100D120D150D0F0D0D0D130D160D150D210D130D130D130D130D100D160D170D2306003D003E003E003E003B003B018014EE33B3063A9800025864000000000000E20A
```

# Mise en place
## Préparation du conteneur
Copier fichier _socat-serial-1.service_ dans /etc/systemd/system/

Copier fichier _socat-serial-2.service_ dans /etc/systemd/system/

Copier fichier _domoticz_bat1.sh_ dans /root

Copier fichier _domoticz_bat2.sh_ dans /root

Copier fichier _cmd_bat.sh_ dans /root

## Installation des dépendances
```
apt install bc curl socat
```
## Mise en palce de Socat au démarrage
Dans le cadre de mon installation Socat fait le lien entre le boitier [USR-N540](https://www.pusr.com/products/4-port-serial-to-ip-converters-usr-n540.html) est _/dev/ttyVx_
```
systemctl daemon-reload
systemctl enable socat-serial-1
systemctl enable socat-serial-2
systemctl start socat-serial-1
systemctl start socat-serial-2
```
## Création des taches de lancement des scripts
_domoticz_bat1.sh_ et _domoticz_bat2.sh_ se lance au démarrage pour analyser les ports séries et envoyer les données à Domoticz

_cmd_bat.sh_ s'exécute toutes les minutes afin d'envoyer la commande d'interrogation des batteries
```
export VISUAL=nano; crontab -e
@reboot nohup /root/domoticz_bat1.sh
@reboot nohup /root/domoticz_bat2.sh
*/1 * * * * nohup /root/cmd_bat.sh
```
## Adaptations
Il y a plusieurs éléments qui seront à adapter à vos besoins :

- Le/Les port(s) séries _/dev/tty**_
- Le fichier _cmd_bat.sh_, celcui-ci utilise les commandes de demande d'information pour des pack avec adresse 0 et 1, si vous disposez de plus de batteries il faudrait trouver les trames correspondantes et les ajouter.
- Les fichiers _domoticz_bat1.sh_ et _domoticz_bat2.sh_, en fonction du nombre de batterie utilisé, il faudra ajuster l'IP  de domoticz et les IDX des capteurs
- Si vous utilisez un adaptateur RS232 TCP/IP, il faudra modifier les fichiers _socat-serial-1.service_ et _socat-serial-2.service_ afin de mettre l'IP et les ports correspondants

# Pour les Tests
Il est possible de tester le retour de la batterie à partir du _script echo_bat.sh_, il faut l'exécuter dans un terminal et exécuter _cmd_bat.sh_ dans un second.

Il faudra adapter le port séries _/dev/tty**_ à votre situation
