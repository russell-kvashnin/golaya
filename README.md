# Golaya. Golang project initializer. 

# Installation
```sh
wget https://raw.githubusercontent.com/russell-kvashnin/golaya/master/installer.sh -O - | bash
```
Installation path is: ~/.local/bin

## Usage
By default, command will create project with minimal directory structure.

Available options:
* -f | --full Create full directory structure
* -c | --cleanup Cleanup project directory if exists         

### Minimal directory structure
```shell
minimal
├── api
├── cmd
├── deployments
├── docs
├── internal
├── pkg
├── Dockerfile
├── .dockerignore
├── .gitignore
├── go.mod
├── Makefile
└── README.md
```

### Full directory structure
```shell
full
├── api
├── assets
├── build
├── cmd
├── configs
├── deployments
├── docs
├── examples
├── githooks
├── init
├── internal
├── pkg
├── scripts
├── test
├── third_party
├── tools
├── web
├── website
├── Dockerfile
├── .dockerignore
├── .gitignore
├── go.mod
├── Makefile
└── README.md
```
