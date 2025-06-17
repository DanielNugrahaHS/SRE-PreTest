#!/bin/bash

LOG_DIR="./log"
CURRENT_TIME=$(date +%s)
START_TIME=$((CURRENT_TIME - 600))  #ubah ke 3600 jika ingin ke 60 menit

echo "Executed at $(date -u +"%Y-%m-%dT%H:%M:%S.000Z")"
echo

for logfile in "$LOG_DIR"/*.log; do
  COUNT=0

  while read -r line; do
    if [[ "$line" =~ \[([0-9]{2})/([A-Za-z]+)/([0-9]{4}):([0-9]{2}):([0-9]{2}):([0-9]{2}) ]]; then
      DAY="${BASH_REMATCH[1]}"
      MONTH="${BASH_REMATCH[2]}"
      YEAR="${BASH_REMATCH[3]}"
      HOUR="${BASH_REMATCH[4]}"
      MIN="${BASH_REMATCH[5]}"
      SEC="${BASH_REMATCH[6]}"

      MONTH_NUM=$(date -j -f "%b" "$MONTH" "+%m" 2>/dev/null)

      if [[ -z "$MONTH_NUM" ]]; then continue; fi

      LOG_DATE="$YEAR-$MONTH_NUM-$DAY $HOUR:$MIN:$SEC"
      LOG_TIMESTAMP=$(date -j -f "%Y-%m-%d %H:%M:%S" "$LOG_DATE" "+%s")

      if [[ "$LOG_TIMESTAMP" -ge "$START_TIME" && "$LOG_TIMESTAMP" -le "$CURRENT_TIME" ]]; then
        if echo "$line" | grep -Eq 'HTTP/1.[01]"[[:space:]]500'; then
          ((COUNT++))
        fi
      fi
    fi
  done < "$logfile"

  echo "There were $COUNT HTTP 500 errors in $logfile in the last 10 minutes."
done
