# /bin/sh


# DIRECTORIES
DIR=/etc/pihole
TMP=/tmp
adlistFile=${DIR}/adlists.list
whiteFile=${DIR}/whitelist.txt
blackFile=${DIR}/blacklist.txt
regexFile=${DIR}/regex.list

# COLOURS
COL_NC='\e[0m' # No Color
COL_GREEN='\e[1;32m'
COL_RED='\e[1;31m'

# SYMBOLS
TICK="[${COL_GREEN}\u2714${COL_NC}]"
CROSS="[${COL_RED}\u2714${COL_NC}]"

logo () {
echo -e "
        ${COL_GREEN}.;;,.
        .ccccc:,.
         :cccclll:.      ..,,
          :ccccclll.   ;ooodc
           'ccll:;ll .oooodc
             .;cll.;;looo:.${COL_RED}
                 .. ','.
                .',,,,,,'.
              .',,,,,,,,,,.
            .',,,,,,,,,,,,....
          ....''',,,,,,,'.......
        .........  ....  .........
        ..........      ..........
        ..........      ..........
        .........  ....  .........
          ........,,,,,,,'......
            ....',,,,,,,,,,,,.
               .',,,,,,,,,'.
                .',,,,,,'.
                  ..'''.${COL_NC}
"
}

defaults () {
echo -n "  [?] Do you wish to add default lists to adlists.list? [Y/n] "; read -n1 default && printf "\n"
case $default in
        n|N)
          echo -e "\n  [i] Target: Default adlist.list"
          echo -e "  ${CROSS} Status: Omitted\n"
          ;;
        *)
          echo "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" >> ${DIR}/adlists.lists
          echo "https://mirror1.malwaredomains.com/files/justdomains" >> ${DIR}/adlists.lists
          echo "http://sysctl.org/cameleon/hosts" >> ${DIR}/adlists.lists
          echo "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt" >> ${DIR}/adlists.lists
          echo "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt" >> ${DIR}/adlists.lists
          echo -e "\n  [i] Target: Default adlist.list"
          echo -e "  ${TICK} Status: Restored defaults\n"
          ;;
esac
}


lists () {
echo -e "  [?] What adlist lists do you wish to add?\n"
echo "    [1] Ticked lists (No one whitelisting) [default]"
echo "    [2] Non-crossed lists (Someone usually whitelisting)"
echo -e "    [3] All lists (Someone always whitelisting)\n"
echo -n "  [i] Select [1-3]:  " ; read -n1 type && printf "\n"
case $type in
        2)
            wget -q "https://v.firebog.net/hosts/lists.php?type=nocross" -O ${TMP}/pihole-updater/adlists
            ;;
        3)
	    wget -q "https://v.firebog.net/hosts/lists.php?type=all" -O ${TMP}/pihole-updater/adlists
            ;;
        *)
            wget -q "https://v.firebog.net/hosts/lists.php?type=tick" -O ${TMP}/pihole-updater/adlists
	    ;;
esac
cat /etc/pihole/adlists.list >> ${TMP}/pihole-updater/adlists
sed -i '/hosts-file.net/d' ${TMP}/pihole-updater/adlists
#sed -i '/Shalla-mal/d' $DIR/pihole-updater/adlists
sort -u ${TMP}/pihole-updater/adlists > ${TMP}/pihole-updater/adlists.list
:> ${DIR}/adlists.list && cat ${TMP}/pihole-updater/adlists.list > ${DIR}/adlists.list
echo "  [i] Target: Adlists"
echo -e "  ${TICK} Status: Retrieval successful\n"
}

regex () {
echo -n "  [?] Do you wish to add a regex list? [Y/n] " ; read -n1 regex && printf "\n"
case $regex in
        n|N)
	  echo -e "\n  [i] Target: Regex list"
	  echo -e "  ${CROSS} Status: Omitted\n"
	  ;;
	*)
          wget -q "https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list" -O ${TMP}/pihole-updater/regex
	  cat ${DIR}/regex.list >> ${TMP}/pihole-updater/regex
          sort -u ${TMP}/pihole-updater/regex > ${TMP}/pihole-updater/regex.list
	  :> ${DIR}/regex.list && cat ${TMP}/pihole-updater/regex.list > ${DIR}/regex.list
	  pihole --regex -nr
	  echo -e "\n  [i] Target: Regex list"
	  echo -e "  ${TICK} Status: Successfully added\\n"
	  ;;
esac
}

whitelist () {
echo -n "  [?] Do you wish to add a whitelist?  [Y/n] " ; read -n1 whitelist && printf "\n"
case $whitelist in
	n|N)
	  echo -e "\n  [i] Target: Whitelist"
	  echo -e "  ${CROSS} Status: Omitted\n"
	  ;;
	*)
	  wget -q "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt" -O ${TMP}/pihole-updater/whitelist
	  cat ${DIR}/whitelist.txt >> ${TMP}/pihole-updater/whitelist
	  sort -u ${TMP}/pihole-updater/whitelist > ${TMP}/pihole-updater/whitelist.txt
          :> ${DIR}/whitelist.txt && cat ${TMP}/pihole-updater/whitelist.txt > ${DIR}/whitelist.txt
	  pihole -w -nr
	  echo -e "\n  [i] Target: Whitelist"
	  echo -e "  ${TICK} Status: Successfully added\n"
esac
}

clean () {
:> ${adlistFile}
pihole -w --nuke && pihole -b --nuke && pihole --regex --nuke && pihole --wild --nuke
echo "  [i] Target: Pi-Hole lists"
echo -e "  ${TICK}Status: Successfully cleaned\n"
}

logs () {
echo -n "  [?] Do you wish to flush logs too?  [Y/n] " ; read -n1 logs && printf "\n"
case $logs in
        n|N)
          echo -e "\n  [i] Target: Flush logs"
          echo -e "  ${CROSS}Status: Omitted\n"
          ;;
        *)
          echo -e "\n  [i] Target: Flush logs"
          pihole -f
          echo -e "  ${TICK}Status: Successfully done\n"
          ;;
esac
}

gravity () {
echo -e "  [i] Updating lists...\n"
pihole -g
printf "\n"
}

update () {
echo -n "  [?] Do you wish to check for updates?  [Y/n] " ; read -n1 updates && printf "\n"
case $updates in
	n|N)
	  echo -e "\n  [i] Target: Updates"
	  echo -e "  ${CROSS}Status: Omitted\n"
	  ;;
	*)
	  pihole -up
	  ;;
esac
}

pihole-list-update () {
mkdir -p ${TMP}/pihole-updater
lists
defaults
regex
whitelist
rm -rf ${TMP}/pihole-updater
gravity
}

if [ $1 == "--clean" ] || [ $1 == "-c" ]; then
logo
clean
echo "  [i] Target: Pi-Hole lists"
echo -e "  ${TICK}Status: Successfully cleaned\n"
logs
defaults
gravity
update
fi

if [ $1 == "--clean-update" ] || [ $1 == "-cu" ]; then
logo
clean
echo "  [i] Target: Pi-Hole lists"
echo -e "  ${TICK}Status: Successfully cleaned\n"
pihole-list-update
update
fi

if [ $1 == "--update" ] || [ $1 == "-u" ]; then
logo
pihole-list-update
update
fi
