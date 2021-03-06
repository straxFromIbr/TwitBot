#!/usr/bin/bash


cd $HOME/TwitBot

if test -z $HTTP_PROXY ; then
    HTTP_PROXY=''
fi

tmp_new=$(mktemp)
tmp_prev=$(mktemp)
tmp_log=$(mktemp)
tmp_tl=$(mktemp)
$HOME/.rbenv/shims/twurl '/1.1/statuses/home_timeline.json?count=60' -P $HTTP_PROXY |\
    jq '.[].text'  |\
    grep -v '[BOT]'|\
    grep -v 質問箱 |\
    sed -e 's/RT @[A-Za-z0-9_]*//g'|\
    sed -e 's/@[A-Za-z0-9_]*//g'|\
    sed -e 's/http[\/\:\.0-9a-zA-Z]*//g' |\
    sed -e 's/#[^ ]*//g' |\
    sed -e 's/\\n/ /g' |\
    sed -e 's/\\/ /g' |\
    sed -e 's/"//g' > $tmp_new

cat $tmp_new | wc -l
cp tweets.txt $tmp_prev
cat $tmp_prev $tmp_new |\
        sort |\
        uniq > tweets.txt
    
for i in {1..1} ; do

    tweet=$(cat  tweets.txt | $HOME/.venvs/general_venv/bin/python3 ./markovbot.py )
    echo $tweet
    if ! test  -z $tweet  ; then
        $HOME/.rbenv/shims/twurl -d "status=[BOT] $tweet" /1.1/statuses/update.json  -P $HTTP_PROXY > $tmp_log
        echo 'tweet:'$tweet
    fi

    cat $tmp_log | jq -r '.created_at, .id, .text' | tr '\n' ', '  >> ./twitbot.log
    echo -e '\n' >> ./twitbot.log
done



