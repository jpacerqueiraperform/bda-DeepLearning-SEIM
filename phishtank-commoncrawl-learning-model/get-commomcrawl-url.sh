#!/usr/bin/env bash
# USING OPTION : phishtank

echo "Follow latest archive here : http://commoncrawl.org/2018/10/october-2018-crawl-archive-now-available/ "
echo "List of Top Level Domains : *.com *.net *.org *.co.uk *.ru "

rm CC-MAIN-2018-43-index?url=*.*

wget -O  CC-MAIN-2018-43-index-.com.json  https://index.commoncrawl.org/CC-MAIN-2018-43-index?url=*.com&output=json 
wget -O  CC-MAIN-2018-43-index-.net.json  https://index.commoncrawl.org/CC-MAIN-2018-43-index?url=*.net&output=json 
wget -O  CC-MAIN-2018-43-index-.org.json  https://index.commoncrawl.org/CC-MAIN-2018-43-index?url=*.org&output=json 
wget -O  CC-MAIN-2018-43-index-.co.uk.json  https://index.commoncrawl.org/CC-MAIN-2018-43-index?url=*.co.uk&output=json 
wget -O  CC-MAIN-2018-43-index-.ru.json  https://index.commoncrawl.org/CC-MAIN-2018-43-index?url=*.ru&output=json 

echo "Done!"
