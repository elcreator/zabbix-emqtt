#!/bin/bash

STATS_KEYS=(
  connections/count
  connections/max
  retained/count
  retained/max
  routes/count
  routes/max
  sessions/count
  sessions/max
  subscribers/count
  subscribers/max
  subscriptions/count
  subscriptions/max
  topics/count
  topics/max
)

METRICS_KEYS=(
  packets/publish/received
  packets/pubrel/received
  packets/puback/missed
  packets/disconnect
  packets/pingreq
  packets/pubrec/sent
  messages/qos1/received
  bytes/sent
  packets/unsuback
  packets/pubrec/received
  messages/qos0/received
  messages/qos1/sent
  messages/qos2/dropped
  packets/puback/received
  packets/sent
  packets/publish/sent
  messages/qos0/sent
  packets/connect
  packets/received
  messages/sent
  bytes/received
  messages/qos2/received
  packets/pubrel/sent
  packets/suback
  packets/connack
  messages/dropped
  packets/unsubscribe
  messages/qos2/sent
  packets/pubrec/missed
  packets/pubcomp/sent
  packets/pingresp
  packets/pubrel/missed
  packets/puback/sent
  messages/received
  packets/pubcomp/missed
  packets/pubcomp/received
  packets/subscribe
  messages/retained
)

stats=$(curl --basic -u "$2:$3" -k -s "http://$4:18083/api/v3/stats/")
metrics=$(curl --basic -u "$2:$3" -k -s "http://$4:18083/api/v3/metrics/")

for key in "${STATS_KEYS[@]}"
do
  out="$(jq -r --arg arg "$(printf '%s' $key)" '.data[0] | .[$arg]' <<< $stats)"
  # printf "%s %s\n" $key $out
  zabbix_sender -z 127.0.0.1 -s $1 -k "emqtt[$key]" -o $out > /dev/null 2>&1
done

for key in "${METRICS_KEYS[@]}"
do
  out="$(jq -r --arg arg "$(printf '%s' $key)" '.data[0] | .metrics | .[$arg]' <<< $metrics)"
  # printf "%s %s\n" $key $out
  zabbix_sender -z 127.0.0.1 -s $1 -k "emqtt[$key]" -o $out > /dev/null 2>&1
done
