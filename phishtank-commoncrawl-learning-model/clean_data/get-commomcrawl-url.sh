#!/usr/bin/env bash
# USING OPTION : commomcrawl 

if [ -n "$1" ]; then
  DAILY=$1
else
  DAILY=20181128
fi

echo "Follow latest archive here : http://commoncrawl.org/2018/10/october-2018-crawl-archive-now-available/ "
echo "List of Top Level Domains : *.com *.org *.co.uk *.ru *.net *.cn *.cz *.kp *.us "

rm CC-MAIN-2018-43-index?url=*.*

export http_proxy="http://proxy:3128"
export https_proxy="https://proxy:3128"

wget -O  datafiles/CC-MAIN-2018-43-index-.com.json  https://index.commoncrawl.org/CC-MAIN-2018-43-index?url=*.com&output=json
wget -O  datafiles/CC-MAIN-2018-43-index-.org.json  https://index.commoncrawl.org/CC-MAIN-2018-43-index?url=*.org&output=json
wget -O  datafiles/CC-MAIN-2018-43-index-.co.uk.json  https://index.commoncrawl.org/CC-MAIN-2018-43-index?url=*.co.uk&output=json
wget -O  datafiles/CC-MAIN-2018-43-index-.ru.json  https://index.commoncrawl.org/CC-MAIN-2018-43-index?url=*.ru&output=json

wget -O  datafiles/CC-MAIN-2018-43-index-.net.json  https://index.commoncrawl.org/CC-MAIN-2018-43-index?url=*.net&output=json
wget -O  datafiles/CC-MAIN-2018-43-index-.cn.json  https://index.commoncrawl.org/CC-MAIN-2018-43-index?url=*.cn&output=json
wget -O  datafiles/CC-MAIN-2018-43-index-.cz.json  https://index.commoncrawl.org/CC-MAIN-2018-43-index?url=*.cz&output=json
wget -O  datafiles/CC-MAIN-2018-43-index-.kp.json  https://index.commoncrawl.org/CC-MAIN-2018-43-index?url=*.kp&output=json
wget -O  datafiles/CC-MAIN-2018-43-index-.us.json  https://index.commoncrawl.org/CC-MAIN-2018-43-index?url=*.us&output=json

# unset http_proxy
# unset https_proxy

echo "Done!"
