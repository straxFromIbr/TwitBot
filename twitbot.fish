#!/usr/bin/fish

cd $HOME/TwitBot
if test -z $HTTP_PROXY 
    set -l HTTP_PROXY ''
end
set -l tmp_new (mktemp)
set -l tmp_prev (mktemp)
set -l tmp_log (mktemp)
set -l tmp_tl (mktemp)
$HOME/.rbenv/shims/twurl '/1.1/statuses/home_timeline.json?count=50' -P $HTTP_PROXY |\
    jq '.[].text'  |\
    grep -v '[BOT]'|\
    grep -v 質問箱 |\
    sed -e 's/RT @[A-Za-z0-9_]*//g'|\
    sed -e 's/@[A-Za-z0-9_]*//g'|\
    sed -e 's/http[\/\:\.0-9a-zA-Z]*//g' |\
    sed -e 's/#[^ ]*//g' |\
    sed -e 's/\\\n/ /g' |\
    sed -e 's/"//g' > $tmp_new

cp tweets.txt $tmp_prev
cat $tmp_prev $tmp_new |\
        sort |\
        uniq |\
        shuf > tweets.txt
    
set -l tweet (echo -e (cat  tweets.txt | $HOME/.venvs/general_venv/bin/python3 ./markovbot.py ))
echo $tweet
if not test -z $tweet
    $HOME/.rbenv/shims/twurl -d "status=[BOT] $tweet" /1.1/statuses/update.json  -P $HTTP_PROXY > $tmp_log
end

cat $tmp_log | jq -r '.created_at, .id, .text' | string join ','  >> ./twitbot.log



