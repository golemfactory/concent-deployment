#! /bin/sh -e
geth_address="$1"


message="$(cat<<EOF
{
    "jsonrpc": "2.0",
    "method":  "eath_syncing",
    "params":  [],
    "id":      4
}
EOF
)"


response="$(
    wget                                                                            \
        --output-document -                                                         \
        --quiet                                                                     \
        --header    "Content-Type:application/json"                                 \
        --post-data "$message"                                                      \
        "$geth_address"                                                             \
)"

synchronization_status="$(echo $response | jq '.result')"
if [[ "$synchronization_status" == null ]]; then
    echo "The response from geth failed with an error: \"$response\""
    exit 2
fi
if [[ "$synchronization_status" == "false" ]]; then
    echo SYNCHRONIZED
    exit 0
fi

echo NOT SYNCHRONIZED
exit 1
