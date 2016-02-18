#!/bin/sh
#
# Quick and dirty MySQL InnoDB database finding script.
# David Levey
#
my_running=0;

if [ -f /usr/bin/systemctl ]; then mysql_status=$(systemctl status mysql); else mysql_status=$(service mysql status); fi
is_running=$(echo "$mysql_status" |grep -Po "running"); if [ "$is_running" = "running" ]; then my_running=1; fi

if [ "$my_running" = "1" ]; then
	innodb_tables=$(mysql -e 'select table_schema, table_name, engine from information_schema.tables;' |grep InnoDB |awk '{print $1}' |uniq);

		echo -e "\033[32m \xE2\x9C\x93 \033[00m MySQL is currently running.";
		echo "All found InnoDB databases from the MySQL query:";
		echo "========";
		echo "$innodb_tables";
		echo "========";
else
	innodb_tables=$(find /var/lib/mysql/ -type f -name '*.ibd' |awk -F/ '{print $5}' |sort |uniq);

		echo -e "\033[31m \xE2\x9C\x98 \033[00m MySQL is NOT running.";
		echo "All found InnoDB databases from a recursive find in '/var/lib/mysql/"
		echo "========";
		echo "$innodb_tables";
		echo "========";
fi