# quickStart
Domicon net quick start bash


## bin目录
用来存放可执行程序以及执行脚本

### bin---init.sh 初始化运行环境或启动节点的脚本

启动脚本以后脚本会在终端输出提供两个选项供用户选择，1.初始化环境  2.启动节点，用户仅需要输入1或2即可根据自己的情况继续后面的操作。
#### 1.初始化环境

在用户选择了初始化环境以后，脚本会以一个domicon网络的普通节点的身份初始化所需要的环境的安装，包括：go,git,pnpm,make这几个环境的安装以及配置。在执行完安装程序以后用户需要手动输入命令`source /home/ubuntu/.bashrc`使得配置文件可以生效。

##### 2.启动节点

- 2.1 用户在选择了启动节点以后，终端输出会提供一个输入项询问用户想要作为L1链的chainID是什么，本次测试我们domicon网络将Sepolia作为我们的L1链的chainID，默认选项11155111，用户也可以输入其他chainID，但是并不会加入到domicon测试网中。在完成L1chaiID的输入以后，终端输出会提供提个输入项询问用户想要加入的domicon网络是什么，本次测试网我们domicon网络的chainID为1988，默认情况下即为1988,如果用户输入了其他选项，那么并不会加入到domicon的测试网络中。

- 2.2 用户在完成了上述操作以后会在chain目录下创建存放用户数据的L2chainID为目录的文件夹，这个文件夹中将存放genesis.json以及rollup.json和jwt.txt文件。
- 2.3 执行脚本会自动为用户创建账户，并输出到终端，在实际生产环境中不建议使用此种方式来生成账户，在创建成功后，我们会自动将账户信息记录到`conf/chain-info.properties`中
- 2.4 配置L1的url信息，我们需要通过配置URL以及URL的种类来与L1进行通信，主要是用来查询，终端会询问要与L1进行通信的Url的种类，一般有："alchemy","quicknode","infura","parity","nethermind","debug_geth","erigon","basic","any"这几种。用户可通过输入1，2，3...来选择以上的种类，然后终端会提供一个输入选项询问L1的url是什么，用户再输入以后可以完成本配置
- 2.5 在完成准备配置以后，之前左右的配置信息会被记录到`conf/chain-info.properties`中方便用户查看
- 2.6 记录完配置信息以后会创建一个jwt.txt文件并放入到数据目录中
- 2.7 初始化geth生成创世区块以及基本数据


## bin -- start.sh 启动脚本
   在执行启动脚本以后会读取配置文件，并依次启动geth,node这两个程序，并通过读取log信息截取自己的bootNode信息和staticNode信息。 

## chain目录
用来存放链的数据，以及genesis.json，rollup.json和jwt.txt文件

## conf目录
用来记录一些配置信息，以及pid信息和bootNode信息和staticNode信息。



