#!/bin/bash

##          FUNCTIONS SECTION              ##
#############################################
function function_config(){
		cd /etc/enigma2/e2m3u2bouquet/
		cat > config.xml <<EOF
<config>
		 <supplier>
		     <name>$voorvoegsel</name><!-- Supplier Name -->
		     <enabled>1</enabled><!-- Enable or disable the supplier (0 or 1) -->
		     <settingslevel>expert</settingslevel>
		     <m3uurl><![CDATA[$url/get.php?username=$username&password=$password&type=m3u_plus&output=ts]]></m3uurl><!-- Extended M3U url --> 
		     <epgurl><![CDATA[$urlepg/xmltv.php?username=$usernameepg&password=$passwordepg&next_days=7]]></epgurl><!-- XMLTV EPG url -->
		     <username><![CDATA[uuuuu]]></username><!-- (Optional) will replace USERNAME placeholder in urls -->
		     <password><![CDATA[ppppp]]></password><!-- (Optional) will replace PASSWORD placeholder in urls -->
		     <providerupdate><![CDATA[]]></providerupdate><!-- (Optional) Provider update url -->
			   <providerhideurls>0</providerhideurls><!-- (Optional) Hide Provider urls in plugin -->
		     <iptvtypes>0</iptvtypes><!-- Change all TV streams to IPTV type (0 or 1) -->
		     <streamtypetv></streamtypetv><!-- (Optional) Custom TV stream type (e.g. 1, 4097, 5001 or 5002 -->
		     <streamtypevod></streamtypevod><!-- (Optional) Custom VOD stream type (e.g. 4097, 5001 or 5002 -->
		     <multivod>1</multivod><!-- Split VOD into seperate categories (0 or 1) -->
		     <allbouquet>0</allbouquet><!-- Create all channels bouquet (0 or 1) -->
		     <picons>0</picons><!-- Automatically download Picons (0 or 1) -->
		     <xcludesref>1</xcludesref><!-- Disable service ref overriding from override.xml file (0 or 1) -->
		     <bouqueturl><![CDATA[]]></bouqueturl><!-- (Optional) url to download providers bouquet - to map custom service references -->
		     <bouquetdownload>0</bouquetdownload><!-- Download providers bouquet (uses default url) must have username and password set above - to map custom service references -->
		     <bouquettop>1</bouquettop><!-- Place IPTV bouquets at top (0 or 1) -->
		 </supplier>
</config>
EOF
}

function populateBouquets(){

	[ -f /etc/enigma2/e2m3u2bouquet/config.xml ] && echo "Config aanwezig" || echo "Config niet aanwezig"
	python e2m3u2bouquet.py
exit
}

function printArt(){
		echo -e "\e[32m     ____.__.__      \e[97m   .__  .__          ______\e[31m_______________________"
		echo -e "\e[32m    |    |__|  | ____\e[97m_  |  | |__|         \_   _\e[31m____/\_____  \______   \""
		echo -e "\e[32m    |    |  |  | \__ \e[97m \ |  | |  |  ______  |    \e[31m__)_  /  ____/|    |  _/"
		echo -e "\e[32m/\__|    |  |  |__/ _\e[97m_ \|  |_|  | /_____/  |    \e[31m    \/       \|    |   \""
		echo -e "\e[32m\________|__|____(___\e[97m_  /____/__|         /_____\e[31m__  /\_______ \______  /"
		echo -e "                      \e[97m\/                         \e[31m \/         \/      \/ \e[0m"
		echo -e "\e[0m"
		echo -e "\e[0m"
	
}

clear
printArt
echo ""
echo ""
wget -q -O - http://127.0.0.1/web/about > /tmp/about.txt
echo -e "> \e[1mEven geduld Image uitlezen! \e[0m"
sleep 1s

############# END FUNCTIONS #####################
#  uitlezen van 1.type ontvanger 2.Image Makers -   #
#             ipadress en versie image?             #
#####################################################
ONTVANGER=$(awk -F'[<>]' '/<e2model>/{print $3}' /tmp/about.txt )
IMAGE=$(awk -F'[<>]' '/<e2distroversion>/{print $3}' /tmp/about.txt)
IPADRES=$(awk -F'[<>]' '/<e2lanip>/{print $3}' /tmp/about.txt )
echo ""
echo ""
echo -e "> \e[0mOntvanger \e[1m$ONTVANGER \e[0mgevonden met image \e[1m$IMAGE \e[0mop ipadres \e[1m$IPADRES \e[0m"
echo ""
echo ""
echo -e "\e[1mMAAK HIERONDER UW KEUZE\e[0m"
echo -e "1\e[33m|\e[0m Installeer E2B.   \e[33m|\e[0m"
echo -e "2\e[33m|\e[0m Bestaande updaten.\e[33m|\e[0m"
echo -e "3\e[33m|\e[0m Verwijder E2B.    \e[33m|\e[0m"
echo -e "9\e[33m|\e[0m Script stoppen    \e[33m|\e[0m"
read -p "Kies:" menu
if [ $menu -eq 9 ]; then
exit;
fi
if [ $menu -eq 2 ]; then
	python /etc/enigma2/e2m3u2bouquet/e2m3u2bouquet.py
exit;
fi
if [ $menu -eq 3 ]; then
	python /etc/enigma2/e2m3u2bouquet/e2m3u2bouquet.py -U
exit;
fi
if [ $menu -eq 1 ]; then
	clear
	printArt
	echo ""
	echo ""
	echo "> Even geduld ... Update Pakketten ..."

	#     Pakketen update voor we gaan beginnen         #
	#####################################################
	opkg update  &>/dev/null

	echo -e "> Linux Pakketten \e[32mSuccesvol \e[0mupgedated"
	echo ""
	echo ""
	#                 BASH installatie                  #
	#####################################################
	echo -e "> Installatie Bash...[1/5]"
	BASHVERSIE=$( opkg list_installed bash* )

	if opkg list_installed bash* | grep "bash*" &>/dev/null
		then
			echo -e "> \e[1mVersie $BASHVERSIE is al \e[32mgeinstalleerd!\e[32m[\e[32m1\e[32m/5]\e[0m"
		else
		echo -e "> \e[1mInstallatie BASH gestart\e[0m"
		opkg install bash &>/dev/null
	fi
	echo ""
	echo ""

	#     Blackhole check Crond via busybox v1.32       #
	#            Anders installeer busybox              #
	#####################################################
	if [ "$IMAGE" = "BlackHole" ]; then
		echo -e "> \e[1mBlackHole image controleren op Crond\e[0m"
		if opkg list_installed busybox - 1* | grep "busybox - 1*" &>/dev/null
			then
				echo -e "> Crond is al \e[32mgeinstalleerd!\e[0m"
			else
			echo -e "> \e[1mInstallatie BASH gestart\e[0m"
			opkg install busybox &>/dev/null
		fi

		#     Blackhole niet gevonden dus zoeken op cron    #
		#####################################################
	else
	CRONVERSIE=$( opkg list_installed *cron* )
	echo -e "> Installatie Cron...[2/5]"
	if opkg list_installed *cron* | grep "cron*" &>/dev/null
		then
			echo -e "\e[1m> Versie $CRONVERSIE is al \e[32mgeinstalleerd! \e[32m[\e[32m2\e[32m/\e[32m5]\e[0m"
		else
		echo -e "> \e[1m> Cron niet \e[31maanwezig! \e[0mWordt nu installeerd!!"
		opkg install cron &>/dev/null
		opkg install busybox-cron &>/dev/null
	fi
fi
echo ""
echo ""
CURLVERSIE=$( opkg list_installed curl* )
echo -e "> \e[0mInstallatie Curl...[3/5]"
if opkg list_installed *curl* | grep "curl*" &>/dev/null
	then
		echo -e "> \e[1mVersie $CURLVERSIE is al \e[32mgeinstalleerd!\e[32m[\e[32m3\e[32m/\e[32m5]\e[0m"
	else
	echo -e "> \e[1mCurl niet \e[31maanwezig! \e[0mWordt nu installeerd!!"
	opkg install curl &>/dev/null
fi

echo ""
echo ""
if [ "$IMAGE" = "BlackHole" ]; then
	echo -e "> \e[1mBlackHole image heeft RDATE, Installatie Ntpdate onnodig\e[0m"
	echo -e "> \e[1mBlackHole klok wordt ingesteld via internet ... \e[33mntp1.inrim.it\e[1m"
	echo -e " \e[32m"
	rdate -s ntp1.inrim.it
	echo -e " \e[0m"
else
KLOKVERSIE=$( opkg list_installed ntpdate* )
echo -e "> \e[0mInstallatie Ntpdate...[4/5]"
if opkg list_installed ntpdate* | grep "ntpdate*" &>/dev/null
	then
		echo -e "> \e[1mVersie $KLOKVERSIE is al \e[32mgeinstalleerd!\e[32m[\e[32m4\e[32m/\e[32m5]\e[0m"
		opkg install ntpdate &>/dev/null
	fi
	ntpdate 0.pool.ntp.org &>/dev/null
	NU=$(date)
	echo -e "> \e[1mSysteem EPG klok ingesteld op: \e[33m$NU\e[0m"
fi
echo -e " \e[0m"
echo -e " \e[0m"
PYTHONARG=$( opkg list_installed python-argpars*)
echo -e "> Installatie Python Args...[5/5]"
if opkg list_installed python-argpars* | grep "*argparse*" &>/dev/null
			then
					echo -e "> \e[1mVersie $PYTHONARG is al \e[32mgeinstalleerd!\e[32m[\e[32m4\e[32m/\e[32m5]\e[0m"
			else
					opkg install python-image python-imaging python-argparse &>/dev/null
					echo -e "> \e[1mVersie $PYTHONARG is al \e[32mgeinstalleerd!\e[32m[\e[32m5\e[32m/\e[32m5]\e[0m"
			fi
		echo ""
		echo ""
		echo -e "\e[1mMAAK HIERONDER UW KEUZE\e[0m"
		echo -e "1\e[33m|\e[0m Installeer E2B.  \e[33m|\e[0m"
		echo -e "2\e[33m|\e[0m E2B + Plugin .   \e[33m|\e[0m"
		echo -e "9\e[33m|\e[0m Script stoppen\e[33m   |\e[0m"
		read -p "Kies:" menu
		if [ $menu -eq 2 ]; then
			wget -O /tmp/enigma2-plugin-extensions-e2m3u2bouquet_0.8.5_all.ipk "https://github.com/su1s/e2m3u2bouquet/releases/download/v0.8.5/enigma2-plugin-extensions-e2m3u2bouquet_0.8.5_all.ipk" && opkg install --force-reinstall /tmp/enigma2-plugin-extensions-e2m3u2bouquet_0.8.5_all.ipk
			rm -rf /etc/enigma2/e2m3u2bouquet
			mkdir /etc/enigma2/e2m3u2bouquet
			cd /etc/enigma2/e2m3u2bouquet/
			wget --no-check-certificate https://raw.githubusercontent.com/su1s/e2m3u2bouquet/master/e2m3u2bouquet.py
			chmod 777 e2m3u2bouquet.py	
		fi
		if [ $menu -eq 1 ]; then
			rm -rf /etc/enigma2/e2m3u2bouquet
			mkdir /etc/enigma2/e2m3u2bouquet
			cd /etc/enigma2/e2m3u2bouquet/
			wget --no-check-certificate https://raw.githubusercontent.com/su1s/e2m3u2bouquet/master/e2m3u2bouquet.py
			chmod 777 e2m3u2bouquet.py	
		fi
		mkdir /usr/share/script/ &>/dev/null
			if ( crontab -l | grep e2m3u2bouquet )
			then
					echo -e "> Auto update is al Installeerd"
			else
					echo -e "> Installatie van auto Update"
					newline="0 6,18 * * * /etc/enigma2/e2m3u2bouquet/e2m3u2bouquet.py"
					(crontab -l; echo "$newline") | crontab -
			fi
			clear
			printArt
			echo -e "\e[0m"

			read -p "Url plakken : " varurl
			var=${varurl%&output*}
			password=${var%#'&'*}
			password=${password##*=}
			username=${var#*\?}
			username=${username%%'&'*}
			username=${username#*=}
			url=${var%"${var#*http*.*/}"}
			url=${url%/*}
			read -p "Prefix Naam: " voorvoegsel
			echo -e "\e[0m"
			echo -e "\e[0m"
			echo -e "\e[1mMAAK HIERONDER UW KEUZE\e[0m"
			echo -e "1\e[33m|\e[0m Met EPG.     \e[33m|\e[0m"
			echo -e "2\e[33m|\e[0m Zonder EPG   \e[33m|\e[0m"
			read -p "Kies:" epgurl
			if [ $epgurl -eq 1 ]; then
				  echo -e "Aanmaak config file"
		  		urlepg=$url
		  		usernameepg=$username 
		  		passwordepg=$password
		  		function_config $voorvoegsel,$urlepg,$usernameepg,$passwordepg
		  		
		  	else
		  		urlepg="hhhhh"
		  		usernameepg="USERNAME"
		  		passwordepg="PASSWORD"		  		
		  		function_config $voorvoegsel,$urlepg,$usernameepg,$passwordepg
		  fi
			echo -e "\e[0m"
			echo -e "\e[0m"
			echo -e "\e[1mCONTROLE CHECK!!\e[0m"
			printf '%s\n'  "Provider Url= $url" "Provider Gebruikersnaam= $username" "Provider Paswoord= $password" "Prefix Bouquets= $voorvoegsel"
			echo -e "\e[0m"
			echo -e "\e[1mMAAK HIERONDER UW KEUZE\e[0m"
			echo -e "1\e[33m|\e[0m Alles is juist     \e[33m|\e[0m"
			echo -e "2\e[33m|\e[0m Stop script        \e[33m|\e[0m"
			
			read -p "Kies: " go_door
			if [ $go_door -eq 1 ]; then
					echo -e "\e[0m"
					echo -e "\e[0m"
					echo -e "Bouquets worden aangemaakt !!"
					populateBouquets
						else
						if [ $go_door -eq 1 ]; then
							echo -e "\e[0m"
							echo -e "\e[0m"
							echo -e "Script wordt afgebroken"
							exit
				fi
			fi
			
			

fi # menu 1


exit