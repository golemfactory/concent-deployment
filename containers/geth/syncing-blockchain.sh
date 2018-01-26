#! /bin/sh -e

message=<<EOF
{
    "jsonrpc": "2.0",
    "method":  "eth_syncing",
    "params":  [],
    "id":      4
}
EOF

response="$(
    wget                                                                            \
        --output-document -                                                         \
        --quiet                                                                     \
        --header    "Content-Type:application/json"                                 \
        --post-data "$message"                                                      \
        "geth.default.svc.cluster.local:8545"                                       \
        | jq '.result'                                                              \
)"

if [[ "$response" == "false" ]]; then
    echo READY
    exit 0
fi

echo NOT READY
exit 1
