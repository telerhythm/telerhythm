#!/bin/bash

TELERHYTHM_CACHE_DIR=~/.telerhythm/cache
TELERHYTHM_GCP_TTS_REQUEST_PATH=~/.telerhythm/request.json

mkdir -p $TELERHYTHM_CACHE_DIR

cat | while read LINE
do 
  if [ -e "$TELERHYTHM_CACHE_DIR/$LINE.mp3" ]; then
    mplayer "$TELERHYTHM_CACHE_DIR/$LINE.mp3" &> /dev/null
  else
    sed "s/{text}/$LINE/g" $TELERHYTHM_GCP_TTS_REQUEST_PATH \
    | curl -s -H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
      -H "Content-Type: appcalication/json; charset=utf-8" \
      -d @- https://texttospeech.googleapis.com/v1/text:synthesize \
    | sed 's|audioContent| |' | tr -d '\n ":{}' | base64 --decode \
    | tee "$TELERHYTHM_CACHE_DIR/$LINE.mp3" \
    | mplayer -cache 1024 - &> /dev/null
  fi
done
