#!/bin/sh

HTMLS_DIR=tmp/webhint_inputs

# start server to deliver assets
RAILS_ENV=test bin/rails server -p 3004 -d

# declare error attribute
error=0

# generate webhint report for each page
index=1
no_files=$(ls -l ${HTMLS_DIR} | grep -v ^d | wc -l | sed -e 's/^[ ]*//')
for filename in "$HTMLS_DIR"/*.html; do
    [ -e "$filename" ] || continue
    echo "${index}/${no_files} hint $filename"
    result=$( yarn run hint "$filename" --tracking off )
    exit_code=$?
    echo "Error report:"
    if [ $exit_code -gt 0 ]
    then
      error=1
      echo "\e[41m        \e[0m \e[91mFailures found in $filename\e[0m" #red flag before failure details
      echo "$result" #prints the result, including the JSON
      echo "\e[91mWebHint errors detected.\e[0m  See results above." #another mention that errors are found, also demarks the end of the reuslts
    else
      echo "\e[42m        \e[0m \e[92mNo failures found in $filename\e[0m" #green flag before confirmation that this file passed
    fi
    echo ""
    index=$(($index + 1))
done

# stop server
kill -9 $(cat tmp/pids/server.pid)

# throw error if error exists
if [ $error -gt 0 ]
then
  echo "\e[41mWebhint issues found - test failed\e[0m"
  exit 1 #exit - 0 non fatal, 1 fatal (make fatal once all tests are in place and existing issues solved)
else
  echo "\e[42m      All  Webhint  tests  passed       \e[0m"
  echo "\e[92m                                        \e[0m"
  echo "\e[92m  ########     ###     ######   ######  \e[0m"
  echo "\e[92m  ##     ##   ## ##   ##    ## ##    ## \e[0m"
  echo "\e[92m  ##     ##  ##   ##  ##       ##       \e[0m"
  echo "\e[92m  ########  ##     ##  ######   ######  \e[0m"
  echo "\e[92m  ##        #########       ##       ## \e[0m"
  echo "\e[92m  ##        ##     ## ##    ## ##    ## \e[0m"
  echo "\e[92m  ##        ##     ##  ######   ######  \e[0m"
  echo "\e[92m                                        \e[0m"
  echo "\e[42m      All  Webhint  tests  passed       \e[0m"
fi

