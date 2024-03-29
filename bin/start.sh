#!/bin/bash

# bin path
DOMICON_BIN=$(pwd -P)

# the bash home path
DOMICON_HOME_PATH=${DOMICON_BIN%/bin}

# lib path
DOMICON_ENV="${DOMICON_HOME_PATH}/env"

DOMICON_PKG="${DOMICON_HOME_PATH}/packages"

#root path
ROOT_PATH="/home/ubuntu/"

CHAIN_INFO_FILE=""
CHAIN_CONF_DIR=""
CHAIN_DATA_DIR=""

# domicon sequencer node ,domicon normal node or op normal node, op sequencer node
# value  "d_normal"  match the node type is domicon normal node
# value  "d_sequencer"  match the node type is domicon sequencer node
# value  "op_normal"  match the node type is op normal node
# value  "op_sequencer"  match the node type is op sequencer node
NODETYPE="d_normal"

l2ChainID=""

# join or create chain
TYPE=""

p2p_port=

WS_PORT=

bootnode=

sequencer_address=

batcher_private_key=

proposer_private_key=

l1_RPC_URL=

l1_RPC_KIND=

staticnode=

read_chain_conf() {
    first_folder=$(find $DOMICON_HOME_PATH/conf -mindepth 1 -maxdepth 1 -type d -print -quit)
    first_folder_name=$(basename "$first_folder")
    CHAIN_CONF_DIR=$DOMICON_HOME_PATH/conf/$first_folder_name
    CHAIN_DATA_DIR=$DOMICON_HOME_PATH/chain/$first_folder_name/gethDataDir
    echo "read chain config in $CHAIN_CONF_DIR"
    CHAIN_INFO_FILE=$DOMICON_HOME_PATH/conf/$first_folder_name/chain-info.properties
    
    if [ -f "$CHAIN_INFO_FILE" ];then
        while IFS='=' read -r key value
        do
            key=$(echo $key | tr '.' '_')
            eval ${key}=\${value}
        done < "$CHAIN_INFO_FILE"
    else
        echo "$CHAIN_INFO_FILE not found, existing."
        exit 0
    fi
    
}

start_geth() {
    echo "getting start with geth...."

    cd $DOMICON_BIN
    
    if [ $NODETYPE == "d_normal" ] || [ $NODETYPE == "d_sequencer" ];then
        #domicon node
        if [ $TYPE == "join" ];then
           nohup ./geth --datadir $CHAIN_DATA_DIR --http --http.corsdomain=* --http.vhosts=* --http.addr=0.0.0.0 --http.api=web3,debug,eth,txpool,net,engine,admin --ws --ws.addr=0.0.0.0 --ws.port=$WS_PORT --ws.origins=* --ws.api=debug,eth,txpool,net,engine --syncmode=full --gcmode=archive --maxpeers=10 --networkid=$l2ChainID --authrpc.vhosts=* --authrpc.addr=0.0.0.0 --authrpc.port=8551 --authrpc.jwtsecret=$CHAIN_DATA_DIR/jwt.txt --rollup.disabletxpoolgossip=true --bootnodes $bootnode >> $CHAIN_DATA_DIR/geth.log 2>&1 &
        else
           nohup ./geth --datadir $CHAIN_DATA_DIR --http --http.corsdomain=* --http.vhosts=* --http.addr=0.0.0.0 --http.api=web3,debug,eth,txpool,net,engine,admin --ws --ws.addr=0.0.0.0 --ws.port=$WS_PORT --ws.origins=* --ws.api=debug,eth,txpool,net,engine --syncmode=full --gcmode=archive --maxpeers=10 --networkid=$l2ChainID --authrpc.vhosts=* --authrpc.addr=0.0.0.0 --authrpc.port=8551 --authrpc.jwtsecret=$CHAIN_DATA_DIR/jwt.txt --rollup.disabletxpoolgossip=true  >> $CHAIN_DATA_DIR/geth.log 2>&1 &
            
        fi
    else
        #op node
          nohup ./geth --datadir $CHAIN_DATA_DIR --http --http.corsdomain=* --http.vhosts=* --http.addr=0.0.0.0 --http.api=web3,debug,eth,txpool,net,engine,admin --ws --ws.addr=0.0.0.0 --ws.port=$WS_PORT --ws.origins=* --ws.api=debug,eth,txpool,net,engine --syncmode=full --gcmode=archive --networkid=$l2ChainID --authrpc.vhosts=* --authrpc.addr=0.0.0.0 --authrpc.port=8551 --authrpc.jwtsecret=$CHAIN_DATA_DIR/jwt.txt --rollup.disabletxpoolgossip=true --nodiscover >> $CHAIN_DATA_DIR/geth.log 2>&1 &
    fi
    
    
    
    pidFile="$CHAIN_DATA_DIR/geth.pid"
    if [ ! -f $pidFile ];then
         touch $pidFile
    fi

    echo $! > $pidFile
    echo "geth is started. pid is written into $pidFile."
    echo
}


start_node() {
    echo "getting start with node."
    
    cd $DOMICON_BIN
    
    if [ $TYPE == "create" ];then
        #启动node 并记录bootNode
        if [ $NODETYPE == "d_sequencer" ];then
            nohup ./op-node --l2=http://localhost:8551 --l2.jwt-secret=$CHAIN_DATA_DIR/jwt.txt --sequencer.enabled --sequencer.l1-confs=5 --verifier.l1-confs=4 --rollup.config=$CHAIN_DATA_DIR/rollup.json --rpc.addr=0.0.0.0 --rpc.port=8547 --rpc.enable-admin --l1=$l1_RPC_URL --l1.rpckind=$l1_RPC_KIND  --p2p.listen.ip=0.0.0.0 --p2p.listen.tcp=9003 --p2p.listen.udp=9003 --p2p.sequencer.key=$sequencer_address >> $CHAIN_DATA_DIR/node.log 2>&1 &
            
            
        else
            nohup ./op-node --l2=http://localhost:8551 --l2.jwt-secret=$CHAIN_DATA_DIR/jwt.txt --sequencer.enabled --sequencer.l1-confs=5 --verifier.l1-confs=4 --rollup.config=$CHAIN_DATA_DIR/rollup.json --rpc.addr=0.0.0.0 --rpc.port=8547 --rpc.enable-admin --l1=$l1_RPC_URL --l1.rpckind=$l1_RPC_KIND  --p2p.sequencer.key=$sequencer_address --p2p.disable >> $CHAIN_DATA_DIR/node.log 2>&1 &
        fi
    else
        #需要输入bootnode 进行链接
        if [ $NODETYPE == "d_normal" ];then
            
            input_static
            
            nohup ./op-node --l2=http://localhost:8551 --l2.jwt-secret=./jwt.txt  --verifier.l1-confs=4 --rollup.config=./rollup.json --rpc.addr=0.0.0.0 --rpc.port=8547 --rpc.enable-admin --l1=$l1_RPC_URL --l1.rpckind=$l1_RPC_KIND  --p2p.static=$staticnode --p2p.listen.ip=0.0.0.0 --p2p.listen.tcp=9003 --p2p.listen.udp=9003 --p2p.sequencer.key=$sequencer_address >> $CHAIN_DATA_DIR/node.log 2>&1 &
            
        else
            nohup ./op-node --l2=http://localhost:8551 --l2.jwt-secret=$CHAIN_DATA_DIR/jwt.txt --sequencer.enabled --sequencer.l1-confs=5 --verifier.l1-confs=4 --rollup.config=$CHAIN_DATA_DIR/rollup.json --rpc.addr=0.0.0.0 --rpc.port=8547 --rpc.enable-admin --l1=$l1_RPC_URL --l1.rpckind=$l1_RPC_KIND  --p2p.sequencer.key=$sequencer_address  --p2p.disable >> $CHAIN_DATA_DIR/node.log 2>&1 &
        fi
    fi
    
}

input_static() {
    read -p "Enter an static node info:"  staticnode
    if [ ! -n "$staticnode" ];then
        touch $CHAIN_CONF_DIR/staticnode.txt
        echo "staticnode=$staticnode" >> $CHAIN_CONF_DIR/staticnode.txt
        echo "Please check static node info you want connected in the path $CHAIN_CONF_DIR/staticnode.txt"
    elif [ -z "$staticnode" ];then
        input_static
    fi

}

# write bootnodes file
write_bootnodes_file() {
    echo "find self bootnode info from log."
    
    bootnodeFile="$CHAIN_CONF_DIR/bootnode.txt"
    if ! test -e $bootnodeFile;then
         touch $bootnodeFile
    fi

    i=1
    while true
    do
        num_bootnodes=`grep -c 'Started P2P networking' $CHAIN_DATA_DIR/geth.log`
        if [ $num_bootnodes -ne 0 ];then
            bootnode=`grep 'Started P2P networking' $CHAIN_DATA_DIR/geth.log`
            bootnode=`echo $bootnode | cut -d '=' -f 2 | cut -d ' ' -f 2`
            ips=0
            for i in `ifconfig | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | grep -v '127\|255\|0.0.0.0'`;do
            if [ $ips -eq 0 ];then
              modified=$(echo "$bootnode" | sed "s/@[^:]*:/@$i:/")
              echo -n "$modified" >> $bootnodeFile;
            else
              modified=$(echo "$bootnode" | sed 's/@[^:]*:/@"$i":/')
              echo -n "$modified" >> $bootnodeFile;
            fi
            let ips++
            done
            break
        else
         i=`expr ${i} + 1`
         if [ $i -gt 7 ];then
            echo  "can not find bootnode info, utopia start may have failed, please check $CHAIN_DATA_DIR/geth.log"
            break
         else
            sleep 1
         fi
    fi
    done
}

start_batcher() {
    echo "getting start with batcher."
    
    cd $DOMICON_BIN
    
    nohup ./batcher --l2-eth-rpc=http://localhost:8545 --rollup-rpc=http://localhost:8547 --poll-interval=1s --sub-safety-margin=6 --num-confirmations=1 -safe-abort-nonce-too-low-count=3 --resubmission-timeout=30s --rpc.addr=0.0.0.0 -rpc.port=8548 --rpc.enable-admin -max-channel-duration=1 --l1-eth-rpc=$L1_RPC_URL --private-key=$batcher_private_key >> $CHAIN_DATA_DIR/batcher.log 2>&1 &
}

start_proposer() {
    echo "getting start with proposer."
    
    cd $DOMICON_BIN
    
    nohup .op-proposer --poll-interval=12s --rpc.port=8560 --rollup-rpc=http://localhost:8547 --l2oo-address=$(cat ../packages/contracts-bedrock/deployments/getting-started/L2OutputOracleProxy.json | jq -r .address) --private-key=$proposer_private_key --l1-eth-rpc=$L1_RPC_URL >> $CHAIN_DATA_DIR/proposer.log 2>&1 &

}


main() {
    read_chain_conf
    start_geth
    write_bootnodes_file
    start_node
    if [ $NODETYPE == "d_sequencer" ] || [ $NODETYPE == "op_sequencer" ];then
        start_batcher
        
        start_proposer
    fi
    
}

main
