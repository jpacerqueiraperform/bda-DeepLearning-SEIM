#!/usr/bin/env bash
# USING OPTION : phishtank

echo "Follow latest archive here : http://commoncrawl.org/2018/10/october-2018-crawl-archive-now-available/ "
echo "List of Top Level Domains : *.com *.net *.org *.co.uk *.ru "

sed -n -e 's/^.*\({"url":\)/\1/p' CC-MAIN-2018-43-index-.com.json >> clean-CC-MAIN-2018-43-index-.com.json
mv clean-CC-MAIN-2018-43-index-.com.json seim/

sed -n -e 's/^.*\({"url":\)/\1/p' CC-MAIN-2018-43-index-.net.json >> clean-CC-MAIN-2018-43-index-.net.json
mv clean- CC-MAIN-2018-43-index-.net.json seim/

sed -n -e 's/^.*\({"url":\)/\1/p' CC-MAIN-2018-43-index-.org.json >> clean-CC-MAIN-2018-43-index-.org.json
mv clean-CC-MAIN-2018-43-index-.org.json seim/

sed -n -e 's/^.*\({"url":\)/\1/p' CC-MAIN-2018-43-index-.co.uk.json >> clean-CC-MAIN-2018-43-index-.co.uk.json
mv clean-CC-MAIN-2018-43-index-.co.uk.json seim/

sed -n -e 's/^.*\({"url":\)/\1/p' CC-MAIN-2018-43-index-.ru.json >> clean-CC-MAIN-2018-43-index-.ru.json
mv clean-CC-MAIN-2018-43-index-.ru.json seim/

echo "Done!"
