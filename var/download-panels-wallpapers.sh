#!/bin/sh
URL='https://storage.googleapis.com/panels-api/data/20240916/media-1a-i-p~s'
for f in $(wget -O - "$URL" | jq -r '.data[].dhd' | grep -v -w null); do
	wget -O "$(basename $(echo "$f" | sed 's/\?.*//'))" "$f"
done
