#!/bin/bash
# 
#  .---.       .     .---.                    
#  \___  . . ,-| ,-. \___  . . ,-. ," ,-. ,-. 
#      \ | | | | | |     \ | | |   |- |-' |   
#  `---' `-^ `-^ `-' `---' `-^ '   |  `-' '   
#                                  '          
#  Welcome to SudoSurfer!
#  This script helps you setting up your servers for production use.
#
#  H:
#  surf.sh | This is your starting point for using SudoSurfer. Running this script starts SudoSurfer and allows you to control it 
#  
#  
# ---------------------
# ---  How to use   ---
# ---------------------
#  Apply correct permissions to surf.sh file:
#     chmod +x surf.sh
#  Run surf.sh:
#     ./surf.sh
#
# ---------------------
# --- Documentation ---
# ---------------------
#  Learn how to use SudoSurfer:
#      Visit https://docs.sudosurfer.com
# 
# ---------------------
# --- Notes & Infos ---
# ---------------------
#  Disclaimer:
#  This script is still alpha and contains bugs.
#  Please don't use it without fully understanding it.
#  Contributions are welcome! :)
#  
# ---------------------
# --- About Author ----
# ---------------------
#  Ivan Dukic | CTO & Solutions Architect at Morgendigital
#  We craft apps and digital experiences for businesses. 
#  Learn more on www.morgendigital.com
# 
# ---------------------

show_help_for_add_user() {
    echo "Add User"
    echo "Command: add user DESIRED_USERNAME [FLAGS]"
    echo "Flags:"
    echo "  --sudo                  Add created user to sudo"
    echo "  -n x                    Number of users to create"
    echo "  -h, --help              Show this help text"
    echo " "
    echo "Example commands: "
    echo "Add user: add user alexa | Replace 'alexa' with your desired username"
    echo "Add 3 users: add user alexa -n 3 | Replace '3' with your desired user amount. In this example, 3 users are created and named as follows: 'alexa1','alexa2','alexa3'"
    echo "Add 3 users: add user alexa --sudo -n 3"
}

install_docker() {
    local source=${1:-"docker-official"}

    case "$source" in
        "docker-official")
            sudo apt-get update
            sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
            sudo apt-get update
            sudo apt-get install -y docker-ce
            ;;
        "docker-io")
            sudo apt-get update
            sudo apt-get install -y docker.io
            ;;
        *)
            echo "Invalid source"
            exit 1
            ;;
    esac
}

setup_python() {
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip
}

setup_c() {
    sudo apt-get update
    sudo apt-get install -y build-essential cmake gcc make
}

command=$1
shift

case $command in
    "add" )
        if [ "$1" = "user" ]; then
            shift
            desired_username=$1
            shift
            sudo_flag=0
            number_of_users=1

            while [ "$1" != "" ]; do
                case $1 in
                    --sudo ) sudo_flag=1 ;;
                    -n ) shift
                         number_of_users=$1 ;;
                    -h | --help ) show_help_for_add_user
                                  exit 0 ;;
                    * ) echo "Unknown flag: $1"
                        exit 1 ;;
                esac
                shift
            done

            for (( i=1; i<=number_of_users; i++ )); do
                username=$([ $number_of_users -eq 1 ] && echo "$desired_username" || echo "${desired_username}${i}")
                sudo adduser $username
                [ $sudo_flag -eq 1 ] && sudo usermod -aG sudo $username
            done
        else
            echo "Invalid command"
            exit 1
        fi
        ;;
    "install" )
        if [ "$1" = "docker" ]; then
            shift
            install_docker $1
        else
            echo "Invalid command"
            exit 1
        fi
        ;;
    "setup" )
        case $1 in
            "python" ) setup_python ;;
            "c" ) setup_c ;;
            * ) echo "Unknown setup command: $1"
                exit 1 ;;
        esac
        ;;
    * ) echo "Invalid command: $command"
        exit 1 ;;
esac
