## wait.sh

`wait.sh` is a bash script inspired by https://github.com/vishnubob/wait-for-it and https://github.com/eficode/wait-for
The script waits for a host or multiple hosts to respond on a TCP port but can also wait for a command to output a value. For example you can wait for a file to exist or contain something.

Like vishnubob's script this is mainly useful to link containers that dependend on one another to start. For example you can have a container that runs install scripts that will have to wait for the database to be accessible.

## Requirement
coreutils needs to be installed

## Usage

```
./wait.sh --help
wait.sh [[-w | --wait "host:port"] | [[-w | --wait "ls -al /var/www"] | [[-c | --command "printenv"] | [[-t | --timeout 10] | [-h | --help]]
-w "HOST:PORT" | --wait "HOST:PORT"             You can specify the HOST and TCP PORT to test 
-w "ls -al /var/www" | --wait "ls -al /var/www" Alternatively you can specify a bash command that should return something
-c "printenv" | --command "printenv"            Command that should be run when all waits are accessible
-t TIMEOUT | --timeout=TIMEOUT                  Timeout untill script is killed. Not interval between calls
-i INTERVAL | --interval=INTERVAL               Interval between calls
-h | --help                                     Usage / Help
```

## Examples

```
$ ./wait.sh --wait "database_host:3306" --wait "ls -al /var/www/html | grep docker-compose.yml" --command "Database is up and files exist"
$ ./wait.sh --wait "database_host:3306" --wait "database_host2:3306" --command "Databases are up"
```

You can set your own timeout with the `-t` or `--timeout=` option.  Setting the timeout value to 0 will disable the delay between requests:

```
$ ./wait.sh --wait "database_host:3306" --wait "database_host2:3306" --command "Databases are up" --timeout 15
```