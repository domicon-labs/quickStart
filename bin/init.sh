#!/bin/bash

# init env or getting start
ACTION="init env"

# join or create chain
TYPE=""

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

# domicon sequencer node ,domicon normal node
# value  "d_normal"  match the node type is domicon normal node
# value  "d_sequencer" match the node type is domicon sequencer node(domicon sequencer node can not deploy by user at this test)
NODETYPE="d_normal"

# go
DOWNLOAD_COMMOND="curl -sSL https://golang.org/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -C /usr/local -xz"

# node
NODE_FILE_PATH="$DOMICON_HOME_PATH/node-v20.11.0-linux-x64.tar.xz"

# pnpm
PNPM_DOWNLOAD_COMM="curl -fsSL https://get.pnpm.io/install.sh | sh -"

# foundry
FOUNDRY_DOWNLOAD_COMM="curl -L https://foundry.paradigm.xyz | bash"

#direnv
DIRENV_DOWNLOAD_COMM="curl -sfL https://direnv.net/install.sh | bash"

DIRENV_HOOK='eval "$(direnv hook bash)"'

# admin
ADMIN_ADDRESS=""
ADMIN_KEY=""

# batcher
BATCHER_ADDRESS=""
BATCHER_KEY=""

# proposer
PROPOSER_ADDRESS=""
PROPOSER_KEY=""

# sequencer
SEQUENCER_ADDRESS=""
SEQUENCER_KEY=""

# env
L1_RPC_KIND=""
L1_RPC_URL=""

# chain id
L1ChainID=5
L2ChainID=1988
L1ChainDEF_ID=5
L2ChainDEF_ID=1988

# main net
MAINNET_ID=""

# test net
TESTNET_ID=1988

# boot to p2p connect
BOOTNODEINFO="enode://dbffc218798fd2febbb1106aa910d336b33bc1b01267a9181b7411af57b37751f9ebcf24e5264dd5fc7fb7572d799d5830882445de76e334590d4662c2a23034@13.212.115.195:30303"

# initialize a utopia blockchain
initenv_getstart() {
    PS3="Please pick an option: "
    select opt in "init env" "getting start"; do
        case "$REPLY" in
            1 ) ACTION="init env"; break;;
            2 ) ACTION="getting start"; break;;
            *) echo "Invalid option, please retry";;
        esac
    done
    
    select_node_type
}

select_node_type() {
    NODETYPE="d_normal"
    if [ "$ACTION" == "init env" ];then
            ##init env
            echo "exec apt-get updating...."
            sudo apt-get update
        if [ $? -eq 0 ]; then
              echo "normal node"
              install_go
              install_git
              install_pnpm
              install_make
        else
            echo "Sudo apt-get update failed，please check nternet or do it on your own。"
        fi
    
    else
        # starting a node
        select_l1chain_id
    fi
}

install_go() {
    echo "Download go package and uncompressing....."
    eval "$DOWNLOAD_COMMOND"
    if [ $? -eq 0 ]; then
        echo "Download and uncompressed success."
        # 添加Go相关环境变量到~/.bashrc
        echo -e "export PATH=\$PATH:/usr/local/go/bin\nexport GOPATH=/home/ubuntu\nexport PATH=\$PATH:/home/ubuntu/bin" >> ~/.bashrc
        echo "Go env needed is done."
    else
        echo "Download and uncompressed failed，please check nternet or do it on your own：$DOWNLOAD_COMMOND"
    fi
}

install_git() {
    echo "Update git....."
    sudo apt-get install -y git
    if [ $? -eq 0 ]; then
        echo "Git is success."
    else
        echo "Git update failed，please check nternet or do it on your own."
    fi
}

install_pnpm() {
    echo "Update pnpm....."
    eval "$PNPM_DOWNLOAD_COMM"
    if [ $? -eq 0 ]; then
        echo "Pnpm update successful."
    else
        echo "Pnpm update failed，please check nternet or do it on your own."
    fi
}

install_make() {
    echo "Update make...."
    sudo apt-get install make
    if [ $? -eq 0 ]; then
       echo "Update make success"
       
    echo 'NOTE!!! You should do !!!:  1.Do source /home/ubuntu/.bashrc. When initenv.sh is finished.'
    else
       echo "Update make failed"
    fi
}

select_l1chain_id() {
    TYPE="join"
    read -p "Enter the L1 blockchain id to connect default L1 chainID is Sepolia chainID [11155111]:"  L1ChainID
    L1ChainID=${L1ChainID:-$L1ChainDEF_ID}
    expr $L1ChainID + 0 &>/dev/null
    if  [ $? -eq 0 ];then
        select_l2chain_id
    else
        echo "Invalid input, please decide the L1 blockchain id to connect"
        select_l1chain_id
    fi
}

select_l2chain_id() {
    read -p "Enter the L2 blockchain id to $TYPE default is L2 chaiID IS [1988]:"  L2ChainID
    L2ChainID=${L2ChainID:-$L2ChainDEF_ID}
    expr $L2ChainID + 0 &>/dev/null
    if  [ $? -eq 0 ];then
        CHAIN_DATA_DIR=$DOMICON_HOME_PATH/chain/$L2ChainID
        CHAIN_CONF_DIR=$DOMICON_HOME_PATH/conf/$L2ChainID
        CHAIN_INFO_FILE=$CHAIN_CONF_DIR/chain-info.properties
    else
        echo "Invalid input, please decide the L2 blockchain id to $TYPE"
        select_l2chain_id
    fi
}

init_datapath() {
    # remove existing one
    if [ -d "$CHAIN_DATA_DIR" ];then
        rm -rf $CHAIN_DATA_DIR
        rm -rf $CHAIN_CONF_DIR
    fi
    
    mkdir -p $CHAIN_DATA_DIR/gethDataDir
    mkdir -p $CHAIN_CONF_DIR
    
    touch $CHAIN_INFO_FILE
}

create_account() {
    echo "Creat new accounts....."
    # Generate wallets
    wallet1=$(cast wallet new)
    
    # Grab wallet addresses
    BROADCAST_ADDRESS=$(echo "$wallet1" | awk '/Address/ { print $2 }')
 
    # Grab wallet private keys
    BROADCAST_KEY=$(echo "$wallet1" | awk '/Private key/ { print $3 }')
   

   # Print out the environment variables to copy
    echo "Please check accounts info:"
    echo
    echo "# Admin account"
    echo "export GS_BROADCAST_ADDRESS=$BROADCAST_ADDRESS"
    echo "export GS_BROADCAST_PRIVATE_KEY=$BROADCAST_KEY"
    echo
    echo "Account info will written into $CHAIN_INFO_FILE later"
}

config_url() {
    echo "Please conf the environment variable file...."
    echo
    PS3="Please pick an option that Kind of L1 RPC you're connecting to, used to inform optimal transactions receipts fetching.: "
    select opt in "alchemy" "quicknode" "infura" "parity" "nethermind" "debug_geth" "erigon" "basic" "any"; do
        case "$REPLY" in
            1 ) L1_RPC_KIND="alchemy"; break;;
            2 ) L1_RPC_KIND="quicknode"; break;;
            3 ) L1_RPC_KIND="infura"; break;;
            4 ) L1_RPC_KIND="parity"; break;;
            5 ) L1_RPC_KIND="nethermind"; break;;
            6 ) L1_RPC_KIND="debug_geth"; break;;
            7 ) L1_RPC_KIND="erigon"; break;;
            8 ) L1_RPC_KIND="any"; break;;
            *) echo "Invalid option, please retry";;
        esac
    done
    echo
    
   
    while true; do
    read -p "Enter the L1_RPC_URL: " L1_RPC_URL
    # 判断输入是否为空
    if [ -z "$L1_RPC_URL" ]; then
        echo "Error: Input cannot be empty. Please enter a valid L1_RPC_URL."
    else
        break  # 用户输入不为空，退出循环
    fi
    done

    echo "L1 RPC kind and URL will written into $CHAIN_INFO_FILE later."
    echo
}

P2P_PORT=30303

write_env_conf() {
    echo "writting chain config into $CHAIN_INFO_FILE"
    # write net info
    echo "l1_RPC_URL=$L1_RPC_URL" > $CHAIN_INFO_FILE
    echo "l1_RPC_KIND=$L1_RPC_KIND" >> $CHAIN_INFO_FILE
    echo "l1ChainID=$L1ChainID" >> $CHAIN_INFO_FILE
    echo "l2ChainID=$L2ChainID" >> $CHAIN_INFO_FILE
    echo "host=127.0.0.1" >> $CHAIN_INFO_FILE
    echo "p2p_port=$P2P_PORT" >> $CHAIN_INFO_FILE
    echo "NODETYPE=$NODETYPE" >> $CHAIN_INFO_FILE
    echo "TYPE=$TYPE" >> $CHAIN_INFO_FILE
    
    
    # write account info
    echo "BROADCAST_ADDRESS=$BROADCAST_ADDRESS" >> $CHAIN_INFO_FILE
    echo "BROADCAST_PRIVATE_KEY=$BROADCAST_KEY" >> $CHAIN_INFO_FILE
   
    # write bootnode info
    echo "bootnode=$BOOTNODEINFO" >> $CHAIN_INFO_FILE
    
    echo "chain config info is written into $CHAIN_INFO_FILE,please check that."
    echo
}

generate_files() {
    echo "starting generate jwt file."

    cd "$CHAIN_DATA_DIR"
    
    openssl rand -hex 32 > $CHAIN_DATA_DIR/jwt.txt && wait
    
    echo "jwt.txt is created in created in $CHAIN_DATA_DIR"
    echo
}


init_geth() {
    echo "starting init geth data...."
    
    cd "$DOMICON_BIN"
    
    cp $DOMICON_HOME_PATH/chain/genesis.json  $CHAIN_DATA_DIR
    
    #需要执行domicon geth
    ./geth init --datadir="$CHAIN_DATA_DIR/gethDataDir" "$CHAIN_DATA_DIR/genesis.json" && wait

    echo "geth is inited."
    echo
    
}

main() {
    initenv_getstart
    if [ "$ACTION" == "getting start" ];then
        ##创建目录
        init_datapath
        ##创建账户
        create_account
        ##填写l1 url
        config_url
        ##将配置记录下来
        write_env_conf
        #创建jwt
        generate_files
        #init geth
        init_geth
    fi
}

main
