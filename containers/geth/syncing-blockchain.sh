#! /bin/sh -e

geth_address="$1"


message=$(cat<<EOF
{
    "jsonrpc": "2.0",
    "method":  "eth_syncing",
    "params":  [],
    "id":      4
}
EOF
)


response="$(
    wget                                                                            \
        --output-document -                                                         \
        --quiet                                                                     \
        --header    "Content-Type:application/json"                                 \
        --post-data "$message"                                                      \
        "$geth_address"                                                             \
)"

synchronization_status="$($response | jq '.result')"
if [ -z "$synchronization_status" ]; then
    echo "The response from geth failed with an error: \"$response\""
    exit 2
fi
if [[ "$response" == "false" ]]; then
    echo READY
    exit 0
fi

echo NOT READY
exit 1
