#!/usr/bin/env python3

import rlp
import json
import argparse
import os

from ethereum.transactions import Transaction
from web3 import Web3, HTTPProvider, IPCProvider
from ethereum.tools.keys import decode_keystore_json


def parse_args():
    parser = argparse.ArgumentParser(description = "Send raw transaction")
    parser.add_argument('--address', dest = "address", required = True, type = str, help = "Ethereum address which receive ether")
    parser.add_argument('--ammount', dest = "ammount", required = True, type = int, help = "Ammount of ether which was send to recevier")

    return parser.parse_args()



def send_transaction(args):
    web3 = Web3(HTTPProvider('http://geth:8545'))

    tx = Transaction(
        nonce = web3.eth.getTransactionCount("0xf51aca2f0883520d7fd77a6cab426c57372b3fe6"),
        gasprice = web3.eth.gasPrice,
        startgas = 100000,
        to = str(args.address),
        value = args.ammount,
        data = b'',
    )

    password=os.environ["ETHEREUM_ACCOUNT_PASSWORD"]
    key = decode_keystore_json(json.load(open(
        '/usr/keystore/UTC--2018-01-18T10-36-50.318254820Z--f51aca2f0883520d7fd77a6cab426c57372b3fe6')), 
        password)


    tx.sign(key)
    raw_tx = rlp.encode(tx)
    raw_tx_hex = web3.toHex(raw_tx)

    return web3.eth.sendRawTransaction(raw_tx_hex)

def main():
    args = parse_args()
    send_transaction(args)

if __name__ == "__main__":
    main()
