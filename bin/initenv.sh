#!/bin/bash

# init env or getting start
ACTION="init env"

# bin path
DOMICON_BIN=$(pwd -P)

# the bash home path
DOMICON_HOME_PATH=${DOMICON_BIN%/bin}

# lib path
DOMICON_ENV="${DOMICON_HOME_PATH}/env"

#root path
ROOT_PATH="/home/ubuntu/"

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
     
    echo "exec apt-get updating...."
    sudo apt-get update
    if [ $? -eq 0 ]; then
      if [ $NODETYPE == "d_sequencer" ] || [ $NODETYPE == "op_sequencer" ]; then
        install_go
        install_git
        install_node
        install_pnpm
        instll_foundry
        install_make
        instll_jq
        install_direnv
      elif [ $NODETYPE == "d_normal" ] || [ $NODETYPE == "op_normal" ]; then
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

main() {
    initenv_getstart
   
    
  
}

main
