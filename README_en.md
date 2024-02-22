# QuickStart
Domicon net quick start bash

## bin directory
Used to store executable programs and execution scripts.

### bin---init.sh Initialization script for running environment or starting nodes
After running the script, two options will be provided for users to choose from in the terminal: 1. Initialize environment 2. Start node. Users only need to enter 1 or 2 to continue the operation according to their own situation.

#### 1. Initialize environment
After the user selects to initialize the environment, the script will install the required environment as an ordinary node of the domicon network, including: go, git, pnpm, make. After the installation program is executed, the user needs to manually enter the command source /home/ubuntu/.bashrc to make the configuration file take effect.

#### 2. Start node
2.1 After the user selects to start the node, the terminal will provide an input prompt asking the user what the chainID for L1 chain should be. In this test, our domicon network will use Sepolia as the chainID of our L1 chain, with the default option being 11155111. Users can also enter other chainIDs, but they will not be added to the domicon testnet. After entering the L1chainID, the terminal will provide an input prompt asking the user what domicon network to join. The chainID of our domicon network for this testnet is 1988, which is the default option. If the user enters other options, they will not join the domicon test network.

2.2 After completing the above operations, the user will create a folder with the L2chainID to store user data under the chain directory. This folder will contain genesis.json, rollup.json, and jwt.txt files.

2.3 The script will automatically create accounts for users and output them to the terminal. This method of generating accounts is not recommended in actual production environments. After successful creation, we will automatically record the account information in conf/chain-info.properties.

2.4 Configure the L1 url information. We need to communicate with L1 by configuring the URL and URL type, mainly for querying. The terminal will prompt for the type of URL to communicate with L1, generally including: "alchemy", "quicknode", "infura", "parity", "nethermind", "debug_geth", "erigon", "basic", "any". Users can choose from the above types by entering 1, 2, 3... The terminal will then prompt for an input option asking what the L1 url is, and users can complete this configuration after entering it.

2.5 After preparing the configuration, the previous configuration information will be recorded in conf/chain-info.properties for users to view conveniently.

2.6 After recording the configuration information, a jwt.txt file will be created and placed in the data directory.

2.7 Initialize geth to generate genesis block and basic data

### bin -- start.sh Start script
After executing the start script, it will read the configuration file, and start the geth and node programs in sequence, and capture its own bootNode information and staticNode information by reading log information.

## chain directory
Used to store chain data, as well as genesis.json, rollup.json, and jwt.txt files.

## conf directory
Used to record some configuration information, as well as pid information, bootNode information, and staticNode information.

