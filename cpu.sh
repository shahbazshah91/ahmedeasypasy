#!/bin/bash

green='\e[32m'
yel='\e[4;33m'
cya='\e[1;36m'
blue='\e[34m'
pur='\e[1;35m'
clear='\e[0m'
GCOLOR="\e[92m ------ OK/HEALTHY \e[0m"
WCOLOR="\e[93m ------ WARNING \e[0m"
CCOLOR="\e[91m ------ CRITICAL \e[0m"
GPCOLOR="\e[92m ------ PERFECT \e[0m"
WCOLOR="\e[93m ------ WARNING \e[0m"
CCOLOR="\e[91m ------ CRITICAL \e[0m"
EndCOLOR="\e[0m"
BIGre='\e[1;92m';
BIRed='\e[1;91m';
BBlu='\e[1;34m';
BCya='\e[1;36m';
red=$'\e[1;31m'
yel=$'\e[1;33m'


APP_STATS () {

    for OUTPUT in $(ls -la /home/master/applications/ | awk '{if(NR>3)print}' | awk '{print $NF}')
    do
    ###### SETUP ############
    LOG_FOLDER=/home/master/applications/$OUTPUT/logs
    ACCESS_LOG=$LOG_FOLDER/apache_*.access.log.1
    SLOW_LOGS=$LOG_FOLDER/php-app.slow.log.1
    HOW_MANY_ROWS=20000
    ######### FUNCTIONS ##############
    function appname() {
        echo -e "
##################################
    "$BIGre $OUTPUT $EndCOLOR"
##################################
    "
    }
    function title() {
        echo "
---------------------------------
    $*
---------------------------------
    "
    }
    function urls_by_ip() {
        local IP=$1
        tail -$HOW_MANY_ROWS $ACCESS_LOG | awk -v ip=$IP ' $1 ~ ip {freq[$7]++} END {for (x in freq) {print freq[x], x}}' | sort -rn | head -5
    }
    function ip_addresses_by_user_agent(){
        local USERAGENT_STRING="$1"
        local TOP_5_IPS="`tail  -$HOW_MANY_ROWS $ACCESS_LOG | grep "${USERAGENT_STRING}"  | awk '{freq[$1]++} END {for (x in freq) {print freq[x], x}}' | sort -rn | head -5`"
        echo "$TOP_5_IPS"
    }
    ####### RUN REPORTS #############
     echo -e "$BIRed *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+ $EndCOLOR"
    appname
    title "top 5 URLs"
    TOP_5_URLS="`tail -$HOW_MANY_ROWS $ACCESS_LOG | awk '{freq[$7]++} END {for (x in freq) {print freq[x], x}}' | sort -rn | head -5`"
    echo "$TOP_5_URLS"
    title "top 5 URLS excluding POST data"
    TOP_5_URLS_WITHOUT_POST="`tail  -$HOW_MANY_ROWS $ACCESS_LOG | awk -F"[ ?]" '{freq[$7]++} END {for (x in freq) {print freq[x], x}}' | sort -rn | head -5`"
    echo "$TOP_5_URLS_WITHOUT_POST"
    title "top 5 IPs"
    TOP_5_IPS="`tail  -$HOW_MANY_ROWS $ACCESS_LOG | awk '{freq[$1]++} END {for (x in freq) {print freq[x], x}}' | sort -rn | head -5`"
    echo "$TOP_5_IPS"
    title "top 5 user agents"
    TOP_5_USER_AGENTS="`/usr/local/sbin/apm -s $OUTPUT traffic -l 24h | sed -n '/Top Bots/,/┌────/p'`"
    echo "$TOP_5_USER_AGENTS"
    title "top 5 slow functions {Count of function, Function, Plugin}"
    TOP_5_SLOW_PLUGINS="`awk '{print $2,$3}' $SLOW_LOGS | grep "wp-content/plugins" | grep -v "session" | grep -v "woocommerce" | grep -v "malcare" | grep -v "elementor" | cut -d? -f1 | sort | uniq -c |sort -nr | head -n 5 | awk 'match($3,/\/wp-content\/plugins\/(\w+)/) {print $1,$2,substr($3,RSTART+20,RLENGTH-20)}'`"
    echo "$TOP_5_SLOW_PLUGINS"
    done

}

APP_STATS
