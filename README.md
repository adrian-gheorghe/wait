## wait.sh

`wait.sh` is a bash script inspired by https://github.com/vishnubob/wait-for-it and https://github.com/eficode/wait-for
The script waits for a host or multiple hosts to respond on a TCP port but can also wait for a command to output a value. For example you can wait for a file to exist or contain something.

The script is mainly useful to link containers that dependend on one another to start. For example you can have a container that runs install scripts that will have to wait for the database to be accessible.

## Requirements
netcat - The machine / container running wait.sh needs to have the netcat service installed.

## Usage

```
./wait.sh --help
wait.sh [[-w | --wait "host:port"] | [[-w | --wait "ls -al /var/www"] | [[-c | --command "printenv"] | [[-t | --timeout 10] | [-h | --help]]
-w "HOST:PORT" | --wait "HOST:PORT"             You can specify the HOST and TCP PORT to test 
-w "ls -al /var/www" | --wait "ls -al /var/www" Alternatively you can specify a bash command that should return something
-c "printenv" | --command "printenv"            Command that should be run when all waits are accessible. Multiple commands can be added
-t TIMEOUT | --timeout=TIMEOUT                  Timeout untill script is killed. Not interval between calls
-i INTERVAL | --interval=INTERVAL               Interval between calls
-h | --help                                     Usage / Help
```

## Examples shell

```
$ ./wait.sh --wait "database_host:3306" --wait "ls -al /var/www/html | grep docker-compose.yml" --command "Database is up and files exist"
$ ./wait.sh --wait "database_host:3306" --wait "database_host2:3306" --command "echo \"Databases are up\""
```

You can set your own timeout with the `-t` or `--timeout=` option.  Setting the timeout value to 0 will disable the delay between requests:

```
$ ./wait.sh --wait "database_host:3306" --wait "database_host2:3306" --command "echo \"Databases are up\"" --timeout 15
```
## Examples docker-compose

```
version: '3.3'
services:
  db:
    image: mysql:5.7
    deploy:
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: database
  wait:
    build:
      context: .
    command: "./wait.sh --wait \"db:3306\" --command \"ls -al\""
    
```

## Example docker multiple FROM

In the following example the Dockerfile adds the wait.sh file from the adighe/wait container. 
The setup allows the running of database migrations only after the database is accessible and the volume is mounted

### Dockerfile
```

FROM adighe/wait as wait
FROM php:7.1.3-fpm

# Install dependencies
RUN apt-get update \
  && apt-get install -y \
    netcat

RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

COPY --from=wait /app/wait.sh /app/wait.sh

ENTRYPOINT ["docker-php-entrypoint"]
CMD ["php-fpm"]
    
```
### docker-compose.yml
```

version: '3.3'
services:
  db:
    image: mysql:5.7
    deploy:
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: database
  install:
      build:
        context: .
      command: "/bin/bash -c \"/app/wait.sh --wait 'db:3306' --wait 'ls -al /var/www/html/ | grep composer.json' --command 'cd /var/www/html' --command 'ls -al' --command 'composer install' --command 'php /var/www/html/bin/console doctrine:migrations:migrate -n -vvv'\""

```