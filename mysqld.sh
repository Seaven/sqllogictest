docker run  -dit --net host -v ${PWD}/mysqld_data:/var/lib/mysql  --rm --name mysql_test -p 3306:3306 -e MYSQL_ROOT_PASSWORD=test -e MYSQL_USER=test -e MYSQL_PASSWORD=test mysql:5.7.31
