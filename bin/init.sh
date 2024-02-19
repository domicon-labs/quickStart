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

# domicon sequencer node ,domicon normal node or op normal node, op sequencer node
# value  "d_normal"  match the node type is domicon normal node
# value  "d_sequencer"  match the node type is domicon sequencer node
# value  "op_normal"  match the node type is op normal node
# value  "op_sequencer"  match the node type is op sequencer node
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
BOOTNODEINFO=""

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
    PS3="Please pick an option that the node type you want: "
    select opt in "domicon sequencer node" "domicon normal node" "op sequencer node" "op normal node"; do
        case "$REPLY" in
            1 ) NODETYPE="d_sequencer"; break;;
            2 ) NODETYPE="d_normal"; break;;
            3 ) NODETYPE="op_sequencer"; break;;
            4 ) NODETYPE="op_normal"; break;;
            *) echo "Invalid option, please retry";;
        esac
    done
     
    if [ "$ACTION" == "init env" ];then
            ##init env
            echo "exec apt-get updating...."
            sudo apt-get update
        if [ $? -eq 0 ]; then
            if [ $NODETYPE == "d_sequencer" ] || [ $NODETYPE == "op_sequencer" ]; then
                echo "sequencer node"
              install_go
              install_git
              install_node
              install_pnpm
              instll_foundry
              install_make
              instll_jq
              install_direnv
            elif [ $NODETYPE == "d_normal" ] || [ $NODETYPE == "op_normal" ]; then
                echo "normal node"
              install_go
              install_git
              install_make
              install_direnv
            else
                echo "Unknow NODETYPE:$NODETYPE"
            fi
        else
            echo "Sudo apt-get update failed，please check nternet or do it on your own。"
        fi
    
    else
        # starting a node
        init_chain_type
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

install_node() {
    echo "Nodejs package uncompressing....."
    cd "$DOMICON_ENV"
    sudo cp node.tar "$ROOT_PATH"
    if [ $? -eq 0 ]; then
        cd "$ROOT_PATH"
        sudo tar -zxf node.tar -C /usr/local
        if [ $? -eq 0 ]; then
            echo "Uncompressed nodejs success."
            echo -e "export PATH=\$PATH:/usr/local/node/bin\n" >> ~/.bashrc
            if [ $? -eq 0 ]; then
                echo "Node env needed is done."
            fi
        fi
    else
        echo "Uncompressing nodejs failed."
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

instll_foundry() {
    echo "Update foundry....."
    FOUNDRY_DOWNLOAD_COMM="curl -L https://foundry.paradigm.xyz | bash"
    eval "$FOUNDRY_DOWNLOAD_COMM"
    if [ $? -eq 0 ]; then
        echo "NOTE!!! You should do !!! : 1.source /home/ubuntu/.bashrc. when initenv.sh is finished. 2. input foundryup in the terminal..... \n"
    else
        echo "Pnpm update failed，please check nternet or do it on your own:$FOUNDRY_DOWNLOAD_COMM."
    fi
}

install_make() {
    echo "Update make...."
    sudo apt-get install make
    if [ $? -eq 0 ]; then
       echo "Update make success"
    else
       echo "Update make failed"
    fi
}

instll_jq() {
    echo "Update jq....."
    sudo apt-get install jq
    if [ $? -eq 0 ]; then
       echo "Update jq success"
    else
       echo "Update jq failed"
    fi
}

install_direnv(){
    DIRENV_HOOK='eval "$(direnv hook bash)"'
    echo -e "\n# direnv hook\n$DIRENV_HOOK" >> ~/.bashrc
    if [ $? -eq 0 ]; then
        echo "Direnv hook is added success in ~/.bashrc"
    else
        echo "Direnv hook is add failed，please check ~/.bashrc file."
    fi
    
    if [ "$ACTION" == "init env" ];then
        if [ "$NODETYPE" == "d_sequencer" ] || [ "$NODETYPE" == "op_sequencer" ]; then
            echo 'NOTE!!! You should do !!!:  1.Do source /home/ubuntu/.bashrc. When initenv.sh is finished.  2.Input: "curl -sfL https://direnv.net/install.sh | bash" do the Direnv Installation.Conf was written into /home/ubuntu/.bashrc file. Please do  source /home/ubuntu/.bashrc again. 3.Input foundryup in the terminal to finished Foundry Installation.'
        elif [ "$NODETYPE" == "d_normal" ] || [ "$NODETYPE" == "op_normal" ];then
            echo 'NOTE!!! You should do !!!: 1.Input: "curl -sfL https://direnv.net/install.sh | bash" do the Direnv Installation.Conf was written into /home/ubuntu/.bashrc file. Please do source /home/ubuntu/.bashrc.'
            
        fi
        
        echo "You can run versions.sh to check version"
    fi
}

init_chain_type() {
    PS3="Please pick an option: "
    select opt in "create a new blockchain" "join an existing blockchain"; do
        case "$REPLY" in
            1 ) TYPE="create"; break;;
            2 ) TYPE="join"; break;;
            *) echo "Invalid option, please retry";;
        esac
    done
    
    select_l1chain_id
}

select_l1chain_id() {
    read -p "Enter the L1 blockchain id to connect default L1 chainID is [5]:"  L1ChainID
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
    
    if [ $TYPE = join ];then
        create_connect_bootnode_file
    fi

}

create_connect_bootnode_file() {
    read -p "Enter an bootnode info:"  BOOTNODEINFO
    if [ ! -n "$BOOTNODEINFO" ];then
        echo "Please check bootnode info you want connected in the path $CHAIN_CONF_DIR/bootnode.txt"
        
        touch $CHAIN_CONF_DIR/bootnode.txt
        echo "bootnode=$BOOTNODEINFO" >> $CHAIN_CONF_DIR/bootnode.txt
    elif [ -z "$BOOTNODEINFO" ];then
        create_connect_bootnode_file
    fi
}

create_genesis() {
    echo "starting create start genesis file...."

    # Get the finalized block timestamp and hash
    block=$(cast block finalized --rpc-url $L1_RPC_URL)
    timestamp=$(echo "$block" | awk '/timestamp/ { print $2 }')
    blockhash=$(echo "$block" | awk '/hash/ { print $2 }')

    if [ "$NODETYPE" == "d_normal" ] || [ "$NODETYPE" == "d_sequencer" ]; then
        # Generate the config file
        config=$(cat << EOL
        {
        "finalSystemOwner": "$ADMIN_ADDRESS",
        "portalGuardian": "$ADMIN_ADDRESS",

        "l1StartingBlockTag": "$blockhash",

        "l1ChainID": $L1ChainID,
        "l2ChainID": $L2ChainID,
        "l2BlockTime": 10,
        "l1BlockTime": 12,

        "maxSequencerDrift": 600,
        "sequencerWindowSize": 3600,
        "channelTimeout": 300,

        "p2pSequencerAddress": "$SEQUENCER_ADDRESS",
        "batchInboxAddress": "0xff00000000000000000000000000000000042069",
        "batchSenderAddress": "$BATCHER_ADDRESS",

        "l2OutputOracleSubmissionInterval": 120,
        "l2OutputOracleStartingBlockNumber": 0,
        "l2OutputOracleStartingTimestamp": $timestamp,

        "l2OutputOracleProposer": "$PROPOSER_ADDRESS",
        "l2OutputOracleChallenger": "$ADMIN_ADDRESS",

        "finalizationPeriodSeconds": 12,

        "proxyAdminOwner": "$ADMIN_ADDRESS",
        "baseFeeVaultRecipient": "$ADMIN_ADDRESS",
        "l1FeeVaultRecipient": "$ADMIN_ADDRESS",
        "sequencerFeeVaultRecipient": "$ADMIN_ADDRESS",

        "baseFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
        "l1FeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
        "sequencerFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
        "baseFeeVaultWithdrawalNetwork": 0,
        "l1FeeVaultWithdrawalNetwork": 0,
        "sequencerFeeVaultWithdrawalNetwork": 0,

        "gasPriceOracleOverhead": 2100,
        "gasPriceOracleScalar": 1000000,

        "enableGovernance": true,
        "governanceTokenSymbol": "DC",
        "governanceTokenName": "Domicon",
        "governanceTokenOwner": "$ADMIN_ADDRESS",

        "l2GenesisBlockGasLimit": "0x1c9c380",
        "l2GenesisBlockBaseFeePerGas": "0x3b9aca00",
        "l2GenesisRegolithTimeOffset": "0x0",

        "eip1559Denominator": 50,
        "eip1559DenominatorCanyon": 250,
        "eip1559Elasticity": 10,

        "systemConfigStartBlock": 0,

        "requiredProtocolVersion": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "recommendedProtocolVersion": "0x0000000000000000000000000000000000000000000000000000000000000000"
        }
    EOL
    )
    
    else
        # Generate the config file
        config=$(cat << EOL
        {
        "finalSystemOwner": "$ADMIN_ADDRESS",
        "portalGuardian": "$ADMIN_ADDRESS",

        "l1StartingBlockTag": "$blockhash",

        "l1ChainID": $L1ChainID,
        "l2ChainID": $L2ChainID,
        "l2BlockTime": 10,
        "l1BlockTime": 12,

        "maxSequencerDrift": 600,
        "sequencerWindowSize": 3600,
        "channelTimeout": 300,

        "p2pSequencerAddress": "$SEQUENCER_ADDRESS",
        "batchInboxAddress": "0xff00000000000000000000000000000000042069",
        "batchSenderAddress": "$BATCHER_ADDRESS",

        "l2OutputOracleSubmissionInterval": 120,
        "l2OutputOracleStartingBlockNumber": 0,
        "l2OutputOracleStartingTimestamp": $timestamp,

        "l2OutputOracleProposer": "$PROPOSER_ADDRESS",
        "l2OutputOracleChallenger": "$ADMIN_ADDRESS",

        "finalizationPeriodSeconds": 12,

        "proxyAdminOwner": "$ADMIN_ADDRESS",
        "baseFeeVaultRecipient": "$ADMIN_ADDRESS",
        "l1FeeVaultRecipient": "$ADMIN_ADDRESS",
        "sequencerFeeVaultRecipient": "$ADMIN_ADDRESS",

        "baseFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
        "l1FeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
        "sequencerFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
        "baseFeeVaultWithdrawalNetwork": 0,
        "l1FeeVaultWithdrawalNetwork": 0,
        "sequencerFeeVaultWithdrawalNetwork": 0,

        "gasPriceOracleOverhead": 2100,
        "gasPriceOracleScalar": 1000000,

        "enableGovernance": true,
        "governanceTokenSymbol": "OP",
        "governanceTokenName": "Optimism",
        "governanceTokenOwner": "$ADMIN_ADDRESS",

        "l2GenesisBlockGasLimit": "0x1c9c380",
        "l2GenesisBlockBaseFeePerGas": "0x3b9aca00",
        "l2GenesisRegolithTimeOffset": "0x0",

        "eip1559Denominator": 50,
        "eip1559DenominatorCanyon": 250,
        "eip1559Elasticity": 10,

        "systemConfigStartBlock": 0,

        "requiredProtocolVersion": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "recommendedProtocolVersion": "0x0000000000000000000000000000000000000000000000000000000000000000"
        }
    EOL
    )
    
    fi
    
    cd "$DOMICON_PKG"; cd ./contracts-bedrock
    touch deploy-config/getting-started.json
    echo "$config" > deploy-config/getting-started.json
    
    echo "getting-started.json is created in deploy-config"
}

create_account() {
    echo "Creat new accounts....."
   
    # Generate wallets
    wallet1=$(cast wallet new)
    wallet2=$(cast wallet new)
    wallet3=$(cast wallet new)
    wallet4=$(cast wallet new)
    
    # Grab wallet addresses
    ADMIN_ADDRESS=$(echo "$wallet1" | awk '/Address/ { print $2 }')
    BATCHER_ADDRESS=$(echo "$wallet2" | awk '/Address/ { print $2 }')
    PROPOSER_ADDRESS=$(echo "$wallet3" | awk '/Address/ { print $2 }')
    SEQUENCER_ADDRESS=$(echo "$wallet4" | awk '/Address/ { print $2 }')

    # Grab wallet private keys
    ADMIN_KEY=$(echo "$wallet1" | awk '/Private key/ { print $3 }')
    BATCHER_KEY=$(echo "$wallet2" | awk '/Private key/ { print $3 }')
    PROPOSER_KEY=$(echo "$wallet3" | awk '/Private key/ { print $3 }')
    SEQUENCER_KEY=$(echo "$wallet4" | awk '/Private key/ { print $3 }')

   # Print out the environment variables to copy
    echo "Please check accounts info:"
    echo
    echo "# Admin account"
    echo "export GS_ADMIN_ADDRESS=$ADMIN_ADDRESS"
    echo "export GS_ADMIN_PRIVATE_KEY=$ADMIN_KEY"
    echo
    echo "# Batcher account"
    echo "export GS_BATCHER_ADDRESS=$BATCHER_ADDRESS"
    echo "export GS_BATCHER_PRIVATE_KEY=$BATCHER_KEY"
    echo
    echo "# Proposer account"
    echo "export GS_PROPOSER_ADDRESS=$PROPOSER_ADDRESS"
    echo "export GS_PROPOSER_PRIVATE_KEY=$PROPOSER_KEY"
    echo
    echo "# Sequencer account"
    echo "export GS_SEQUENCER_ADDRESS=$SEQUENCER_ADDRESS"
    echo "export GS_SEQUENCER_PRIVATE_KEY=$SEQUENCER_KEY"
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
JRPC_PORT=8545
WS_PORT=8546
GRPC_PORT=7390

write_env_conf() {
    echo "writting chain config into $CHAIN_INFO_FILE"
    # write net info
    echo "l1_RPC_URL=$L1_RPC_URL" > $CHAIN_INFO_FILE
    echo "l1_RPC_KIND=$L1_RPC_KIND" >> $CHAIN_INFO_FILE
    echo "l1ChainID=$L1ChainID" >> $CHAIN_INFO_FILE
    echo "l2ChainID=$L2ChainID" >> $CHAIN_INFO_FILE
    echo "host=127.0.0.1" >> $CHAIN_INFO_FILE
    echo "p2p_port=$P2P_PORT" >> $CHAIN_INFO_FILE
    echo "jrpc_port=$JRPC_PORT" >> $CHAIN_INFO_FILE
    echo "ws_port=$WS_PORT" >> $CHAIN_INFO_FILE
    echo "grpc_port=$GRPC_PORT" >> $CHAIN_INFO_FILE
    echo "NODETYPE=$NODETYPE" >> $CHAIN_INFO_FILE
    echo "TYPE=$TYPE" >> $CHAIN_INFO_FILE
    
    
    # write account info
    echo "admin_address=$ADMIN_ADDRESS" >> $CHAIN_INFO_FILE
    echo "admin_private_key=$ADMIN_KEY" >> $CHAIN_INFO_FILE
    echo "batcher_address=$BATCHER_ADDRESS" >> $CHAIN_INFO_FILE
    echo "batcher_private_key=$BATCHER_KEY" >> $CHAIN_INFO_FILE
    echo "proposer_address=$PROPOSER_ADDRESS" >> $CHAIN_INFO_FILE
    echo "proposer_private_key=$PROPOSER_KEY" >> $CHAIN_INFO_FILE
    echo "sequencer_address=$SEQUENCER_ADDRESS" >> $CHAIN_INFO_FILE
    echo "sequencer_private_key=$SEQUENCER_KEY" >> $CHAIN_INFO_FILE
    
    # write bootnode info
    echo "bootnode=$BOOTNODEINFO" >> $CHAIN_INFO_FILE
    
    echo "chain config info is written into $CHAIN_INFO_FILE,please check that."
    echo
}

deploy_contract() {
    echo "starting deploy contract....."

    cd "$DOMICON_PKG"; cd ./contracts-bedrock

    forge script scripts/Deploy.s.sol:Deploy --private-key $ADMIN_KEY --broadcast --rpc-url $L1_RPC_URL --slow && wait
    
    echo "Attention!! If you see a nondescript error that includes EvmError: Revert and Script failed then you likely need to change the IMPL_SALT environment variable. This variable determines the addresses of various smart contracts that are deployed via CREATE2. If the same IMPL_SALT is used to deploy the same contracts twice, the second deployment will fail. You can generate a new IMPL_SALT by running ‘direnv allow’."


    forge script scripts/Deploy.s.sol:Deploy --sig 'sync()' --rpc-url $L1_RPC_URL && wait
    
    echo "contract was deployed."
    echo
}

generate_files() {
    echo "starting generate genesis,rollup and jwt file."

    cd "$DOMICON_BIN"
    
    ./main genesis l2 --deploy-config ../packages/contracts-bedrock/deploy-config/getting-started.json --deployment-dir ../packages/contracts-bedrock/deployments/getting-started/ --outfile.l2 $CHAIN_DATA_DIR/genesis.json --outfile.rollup $CHAIN_DATA_DIR/rollup.json --l1-rpc $L1_RPC_URL && wait

    echo "genesis.json and rollup.json is created in $CHAIN_DATA_DIR"
    
    openssl rand -hex 32 > $CHAIN_DATA_DIR/jwt.txt && wait
    
    echo "jwt.txt is created in created in $CHAIN_DATA_DIR"
    echo
}


init_geth() {
    echo "starting init geth data...."
    
    cd "$DOMICON_BIN"
    
    if [ $NODETYPE == "d_sequencer" ] || [ $NODETYPE == "d_normal" ];then
        #需要执行domicon geth
        ./geth init --datadir="$CHAIN_DATA_DIR/gethDataDir" "$CHAIN_DATA_DIR/genesis.json" && wait
    else
        ./geth init --datadir="$CHAIN_DATA_DIR/gethDataDir" "$CHAIN_DATA_DIR/genesis.json" && wait
    fi
    
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
        ##创建genesis的准备文件
        create_genesis
        ##将配置记录下来
        write_env_conf
        ##部署合约
        deploy_contract
        ##创建genesis以及rollup
        generate_files
        #init geth
        init_geth
    fi
}

main
