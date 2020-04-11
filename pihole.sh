# /bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PIHOLE=/etc/pihole

logo () {
echo -e "\e[32m
        .;;,.
        .ccccc:,.
         :cccclll:.      ..,,
          :ccccclll.   ;ooodc
           'ccll:;ll .oooodc
             .;cll.;;looo:.\e[31m
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
                  ..'''.
\e[39m \n"
}

defaults () {
echo -e "Would you like to add default lists to adlists.list? [Y/n]\n"
read -sn1 default
case $default in
        n)
          echo "  [i] Target: Default adlist.list"
          echo -e "  [\e[32m\xE2\x9C\x94\e[39m] Status: Omitted\n"
          ;;
        *)
          echo "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" >> $PIHOLE/adlists.lists
          echo "https://mirror1.malwaredomains.com/files/justdomains" >> $PIHOLE/adlists.lists
          echo "http://sysctl.org/cameleon/hosts" >> $PIHOLE/adlists.lists
          echo "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt" >> $PIHOLE/adlists.lists
          echo "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt" >> $PIHOLE/adlists.lists
          echo "  [i] Target: Default adlist.list"
          echo -e "  [\e[32m\xE2\x9C\x94\e[39m] Status: Restored defaults\n"                                                                                                      ;;
esac
}


lists () {
echo "Select an adlist lists: [1-3]"
echo " [1] Ticked lists (No one whitelisting) [default]"
echo " [2] Non-crossed lists (Someone usually whitelisting)"
echo -e " [3] All lists (Someone always whitelisting)\n"

read -sn1 type
case $type in
        2)
            wget -q "https://v.firebog.net/hosts/lists.php?type=nocross" -O $DIR/pihole-updater/adlists
            ;;
        3)
	    wget -q "https://v.firebog.net/hosts/lists.php?type=all" -O $DIR/pihole-updater/adlists
            ;;
        *)
            wget -q "https://v.firebog.net/hosts/lists.php?type=tick" -O $DIR/pihole-updater/adlists
	    ;;
esac
}


regex () {
echo -e "Would you like to add a regex list? [Y/n]\n"
read -sn1 regex
case $regex in
        n)
	  echo "  [i] Target: Regex list"
	  echo -e "  [\e[32m\xE2\x9C\x94\e[39m] Status: Omitted\n"
	  ;;
	*)
          wget -q "https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list" -O $DIR/pihole-updater/regex
	  cat /etc/pihole/regex.list >> $DIR/pihole-updater/regex
          sort -u $DIR/pihole-updater/regex > $DIR/pihole-updater/regex.list
	  rm /etc/pihole/regex.list
	  mv $DIR/pihole-updater/regex.list /etc/pihole/regex.list
	  echo "  [i] Target: Regex list"
	  echo -e "  [\e[32m\xE2\x9C\x94\\e[39m] Status: Successfully added\\n"
	  ;;
esac
}

whitelist () {
echo -e "Would you like to add a whitelist?  [Y/n]\n"
read -sn1 whitelist
case $whitelist in
	n)
	  echo "  [i] Target: Whitelist"
	  echo -e "  [\e[32m\xE2\x9C\x94\e[39m] Status: Omitted\n"
	  ;;
	*)
	  wget -q "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt" -O $DIR/pihole-updater/whitelist
	  cat /etc/pihole/whitelist.txt >> $DIR/pihole-updater/whitelist
	  sort -u $DIR/pihole-updater/whitelist > $DIR/pihole-updater/whitelist.txt
	  rm /etc/pihole/whitelist.txt
	  mv $DIR/pihole-updater/whitelist.txt /etc/pihole/whitelist.txt
	  echo "  [i] Target: whitelist"
	  echo -e "  [\e[32m\xE2\x9C\x94\\e[39m] Status: Successfully added\n"
esac
}

pihole-list-update () {

mkdir -p $DIR/pihole-updater

echo -e "Updating lists...\n"

lists
defaults
cat /etc/pihole/adlists.list >> $DIR/pihole-updater/adlists
sed -i '/hosts-file.net/d' $DIR/pihole-updater/adlists
#sed -i '/Shalla-mal/d' $DIR/pihole-updater/adlists
sort -u $DIR/pihole-updater/adlists > $DIR/pihole-updater/adlists.list
rm /etc/pihole/adlists.list
mv $DIR/pihole-updater/adlists.list /etc/pihole/adlists.list
echo "  [i] Target: adlists"
echo -e "  [\e[32m\xE2\x9C\x94\e[39m] Status: Retrieval successful\n"
regex
whitelist

rm -rf $DIR/pihole-updater

echo -e "Updating Gravity...\n"
pihole updateGravity

}

if [ $1 == "--clean" ] || [ $1 == "-c" ]; then
logo
: > /etc/pihole/gravity.list && : > /etc/pihole/adlists.list && : > /etc/pihole/whitelist.txt && : > /etc/pihole/regex.txt rm /etc/pihole/list.*
echo "  [i] Target: Pi-Hole lists"
echo -e "  [\e[32m\xE2\x9C\x94\e[39m] Status: Successfully cleaned\n"
defaults
fi

if [ $1 == "--clean-update" ] || [ $1 == "-cu" ]; then
logo
: > /etc/pihole/gravity.list && : > /etc/pihole/adlists.list && : > /etc/pihole/whitelist.txt && : > /etc/pihole/regex.txt rm /etc/pihole/list.*
echo "  [i] Target: Pi-Hole lists"
echo -e "  [\e[32m\xE2\x9C\x94\e[39m] Status: Successfully cleaned\n"
pihole-list-update
fi

if [ $1 == "--update" ] || [ $1 == "" ] || [ $1 == "-u" ]; then
logo
pihole-list-update
fi
