#!/bin/sh

HTMLS_DIR=tmp/webhint_inputs

# delete previously generated html pages
if [ -d "$HTMLS_DIR" ]; then rm -Rf $HTMLS_DIR; fi

# generate HTML pages
SAVE_WEBHINT_STEPS=true bundle exec cucumber --tags "@webhint"

# start server to deliver assets
RAILS_ENV=test bin/rails server -p 3004 -d

# generate webhint report for each page
for filename in "$HTMLS_DIR"/*.html; do
    [ -e "$filename" ] || continue
    echo "hint $filename"
    RESULT=$( npm run hint -- "$filename" --tracking off 2>&1 )
done

# stop server
kill -9 $(cat tmp/pids/server.pid)
