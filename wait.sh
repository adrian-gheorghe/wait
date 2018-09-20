#!/usr/bin/env bash

TIMEOUT=15
INDEX=0
WAITS=()
cmdname=$(basename $0);

usage()
{
    echo "Usage: $cmdname [[-w | --wait \"host:port\"] | [[-w | --wait \"ls -al /var/www\"] | [[-c | --command \"printenv\"] | [[-t | --timeout 15] | [-h | --help]]"
    exit 1
};

waitfor()
{
    DONE=0
    WAITCOMMAND=$1
    while [ "$DONE" -eq 0 ];
    do
        process "$WAITCOMMAND"
    done
}

process()
{
    case "$1" in
        *:* )
        hostport=(${1//:/ })
        HOST=${hostport[0]}
        PORT=${hostport[1]}
        nc -z "$HOST" "$PORT" > /dev/null 2>&1
        result=$?
        if [[ $result -eq 0 ]]; then
            echo "Host $HOST on $PORT is now accessible"
            DONE=1
        else
            echo "Sleeping $TIMEOUT seconds"
            sleep $TIMEOUT
        fi
        ;;
        * )
        command=$(eval ${1})
        if [[ $command && ($? -eq 0) ]]; then
            echo "$1 returned $command"
            DONE=1
         else
            echo "Sleeping $TIMEOUT seconds"
            sleep $TIMEOUT
        fi
        ;;
    esac
}

main()
{
    for ((i = 0; i < ${#WAITS[@]}; i++))
    do
        waitfor "${WAITS[$i]}"
    done

    $COMMAND
    exit 1
}

##### Main
while [ "$1" != "" ]; do
    case $1 in
        -w | --wait )           shift
                                WAITS["$INDEX"]="$1"
                                let "INDEX++"
                                ;;
        -c | --command )        shift
                                COMMAND="$1"
                                ;;
        -t | --timeout )        shift
                                TIMEOUT="$1"
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        *)                      echoerr "Invalid option: $1"
                                usage
                                exit 1
    esac
    shift
done

main
