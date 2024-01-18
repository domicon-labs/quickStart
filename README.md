# quickStart
Domicon net quick start bash


##bin目录
用来存放可执行程序

###bin---initenv.sh 初始化运行环境或启动节点的脚本

启动脚本以后脚本会在终端输出提供两个选项供用户选择，1.初始化环境  2.启动节点，用户仅需要输入1或2即可根据自己的情况继续后面的操作。
####初始化环境

在用户选择了初始化环境以后，脚本会在终端输出四个选项供用户选择，1.domicon sequencer节点，2.domicon普通节点，3.op sequencer节点，4.op普通节点。从初始化环境角度来讲domicon sequencer节点与op sequencer节点所需相同，domicon普通节点与op普通节点所需相同。

所以当用户选择了1或3以后，系统会依次更新并配置go,git,node,pnpm,foundry,make,jq,direnv。在运行完成以后会输出一段提示信息，提示用户需要手动完成的操作:1.source /home/ubuntu/.bashrc。 2.输入“curl -sfL https://direnv.net/install.sh | bash”完成对direnv的安装。3.输入foundryup完成对foundry的安装。
用户选择了2或4以后，系统会依次更新go,git,make,direnv。在运行完成以后会输出一段提示信息，提示用户需要手动完成的操作:1.输入"curl -sfL https://direnv.net/install.sh | bash"完成对direnv的安装并且在结束以后输入source /home/ubuntu/.bashrc。

以上所有环境都已筹备完毕，可以后续操作。



##chain目录
用来存放链的数据

##conf目录
用来记录一些配置信息

##contract目录
用来存放需要部署的合约文件

##env目录
用来存放一些配置环境所需的安装包


