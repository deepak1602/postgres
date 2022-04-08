Backup and Restore Database in PostgreSQL
=========================================
-----Backup Database in PostgreSQL-------
=========================================
To export PostgreSQL database we will need to use the pg_dump tool, which will dump all the contents of a selected database into a single file.

We need to run pg_dump in the command line on the computer where the database is stored. So, if the database is stored on a remote server, you will need to SSH to that server in order to run the following command:
---------------------------------------------------------------------
pg_dump -U db_user -W -F t db_name > /path/to/your/file/dump_name.tar
---------------------------------------------------------------------

Here we used the following options:

		-U to specify which user will connect to the PostgreSQL database server.
		-W or --password will force pg_dump to prompt for a password before connecting to the server.
		-F is used to specify the format of the output file, which can be one of the following:
		-d, –dbname=DBNAME database name
		-h, –host=HOSTNAME database server hostname or ip
		-p, –port=PORT database server port number (default: 5432)
		–role=ROLENAME do SET ROLE before dump
		-j increase the backup , by creating parallel process

		p – plain-text SQL script
		c – custom-format archive
		d – directory-format archive
		t – tar-format archive
		custom, directory and tar formats are suitable for input into pg_restore.


To produce a backup file in custom dump format, you need to add the -Fc option:

			pg_dump -Fc database_name > database.dump
			
	To create a tar file, use the -Ft option:

			pg_dump -Ft database_name -f database.tar
			
	To create a directory-format archive, you need to use the -Fd option:

			pg_dump -Fd database_name -f database.dump
			
			
To see a list of all the available options use pg_dump -?.

With given options pg_dump will first prompt for a password for the database user db_user and then connect as that user to the database named db_name. After it successfully connects,  will write the output produced by pg_dump to a file with a given name, in this case dump_name.tar.

File created in this process contains all the SQL queries that are required in order to replicate your database.

1. Backup Single Database

			Backup: single database in PostgreSQL. Replace your actual database name with mydb.
			$ pg_dump -U postgres -d mydb > mydb.pgsql

2. Backup All Databases

			Backup: all databases in PostgreSQL using pg_dumpall utility.
			$ pg_dumpall -U postgres > alldbs.pgsql

3. Backup Single Table

			Backup: a single table named mytable from mydb database.
			$ pg_dump -U postgres -d mydb -t mytable > mydb-mytable.pgsql

4. Compressed Backup Database

			Backup: PostgreSQL database in compressed format.
			$ pg_dump -U postgres -d mydb | gzip > mydb.pgsql.gz
			
			
	Compressing the backup script

			If you need to compress the output file, you must use the -Z option:
			pg_dump -Z6 database_name > database.gz


5. Split Backup in Multiple Files and Restore

			Backup: PostgreSQL database and split backup in multiple files of specified size. It helps us to backup a large database and transfer to other host easily. As per below example it will split backup files of 100mb in size.

			$ pg_dump -U postgres -d mydb | split -b 100m – mydb.pgsql
			Restore: database backup from multiple splited backup files.

			$ cat mydb.pgsql* | psql -U postgres -d mydb
			Backup: database in compressed splited files of specified size.

			$ pg_dump -U postgres -d mydb | gzip | split -b 100m – mydb.pgsql.gz
			Restore: database from multiple files of compressed files.

			$ cat mydb.pgsql.gz* | gunzip | psql -U postgres -d mydb

6. Simpliest Backup Command 

			pg_dump database_name > database.sql
			or:
			pg_dump database_name -f database.sql
			
			
7. Backing up a remote server

			If you need to back up a remote server add -h and -p options:
			
			pg_dump -h host_name -p port_number database_name > database.sql
			
			
8.The basic usage of this command is as follows:

			pg_dumpall > all_databases.sql
			
9.Split the file in multiple small files

			pg_dumpall | split -b 1k /	location/backupfile
			
=========================================
-----Restore Database in PostgreSQL-------
=========================================

There are two ways to restore a PostgreSQL database: 
psql for restoring from a plain SQL script file created with pg_dump,pg_restore for restoring from a .tar file, directory, or custom format created with pg_dump.

1. Restore a database with psql
			
			If your backup is a plain-text file containing SQL script, then you can restore your database by using PostgreSQL interactive terminal, and running the following command:

			psql -U db_user db_name < dump_name.sql
			where db_user is the database user, db_name is the database name, and dump_name.sql is the name of your backup file.

2. Restore a database with pg_restore
			
			If you choose custom, directory, or archive format when creating a backup file, then you will need to use pg_restore in order to restore your database:

			pg_restore -d db_name /path/to/your/file/dump_name.tar -c -U db_user
			If you use pg_restore you have various options available, for example:

			-c to drop database objects before recreating them,
			-C to create a database before restoring into it,
			-e exit if an error has encountered,
			-F format to specify the format of the archive.


1. Backup Single Database
		
			Restore: single database backup in PostgreSQL.
			$ psql -U postgres -d mydb < mydb.pgsql
			
2. Restore All Databases

			Restore: all database backup using following command.
			$ psql -U postgres < alldbs.pgsql
			
3. Restore Single Table

			Restore: single table backup to database. Make sure your backup file contains only single table backup which you want to restore.
			$ psql -U postgres -d mydb < mydb-mytable.pgsql
			
4. Compressed Restore Database

			Restore: database from compressed backup file directly.
			$ gunzip -c mydb.pgsql.gz | psql -U postgres -d mydb
			
5. Split Backup in Multiple Files and Restore

			Backup: PostgreSQL database and split backup in multiple files of specified size. It helps us to backup a large database and transfer to other host easily. As per below example it will split backup files of 100mb in size.

			$ pg_dump -U postgres -d mydb | split -b 100m – mydb.pgsql
			Restore: database backup from multiple splited backup files.

			$ cat mydb.pgsql* | psql -U postgres -d mydb
			Backup: database in compressed splited files of specified size.

			$ pg_dump -U postgres -d mydb | gzip | split -b 100m – mydb.pgsql.gz
			Restore: database from multiple files of compressed files.

			$ cat mydb.pgsql.gz* | gunzip | psql -U postgres -d mydb
			
6.Restore the PostgreSQL dump file

		Since the text files generated by pg_dump contain a set of SQL commands, they can be fed to the psql utility. The database itself will not be created by psql, so you must create it yourself from template0 first. So, the general command form to restore a dump is:

			createdb -T template0 database_name  psql database_name < database.sql
			
7.Restoring a remote database

		If you need to restore a database on a remote server, you can connect psql to it using -h and -p options:

			psql -h host_name -p port_number database_name < database.sql
		It is possible to dump a database directly from one server to another due to the ability of pg_dump and psql to write to or read from pipes, for example:

			pg_dump -h source_host database_name | psql -h destination_host database_name

8.This command will duplicate a database:

			createdb -T template0 new_database  pg_dump existing_database | psql new_database
		
==========================================		
-----------Error handling-----------------
==========================================		

		If an SQL error occurs, the psql script continues to be executed; this is by default. Such behavior can be changed by running psql with the ON_ERROR_STOP variable, and if an SQL error is encountered, psql exit with an exit status of 3.

			psql --set ON_ERROR_STOP=on database_name < database.sql

		If an error happens, you receive a partially restored database. To avoid this and complete the restoration, either fully successful or fully rolled back, set to restore a whole dump as a single transaction. To do it, use -1 option to psql:

			psql --set ON_ERROR_STOP=on -1 database_name < database.sql
			
			
			
==================================================
How to backup several PostgreSQL databases at once
==================================================

			Pg_dump can dump only one database at a time, and information about tablespaces or roles will not be included in that dump. It happens because those aren’t per-database but cluster-wide. There is a pg_dumpall program that supports convenient dumping of the entire contents of a database cluster. It preserves role and tablespace definitions (cluster-wide data) and performs backups of each database in a given cluster. pg_dumpall works in the following way: it emits commands to re-create tablespaces, empty databases, and roles and then invokes pg_dump for each database. Although each database will be internally consistent, snapshots of different databases may not be fully synchronized.

		The basic usage of this command is as follows:

			pg_dumpall > all_databases.sql
			Psql and option -f can be used to restore the resulting dump:

			psql -f all_databases.sql postgres
		No matter which database you are connecting to, the script file created via pg_dumpall will contain all necessary commands for creation and connection to the saved databases.
		
		

==================================================
-------pg_restore PostgreSQL databases -----------
==================================================

		pg_restore is a utility for restoring a PostgreSQL database from an archive created by pg_dump in one of the non-plain-text formats. It will issue the commands necessary to reconstruct the database to the state it was in at the time it was saved. The archive files also allow pg_restore to be selective about what is restored, or even to reorder the items prior to being restored. The archive files are designed to be portable across architectures.

		pg_restore can operate in two modes. If a database name is specified, pg_restore connects to that database and restores archive contents directly into the database. Otherwise, a script containing the SQL commands necessary to rebuild the database is created and written to a file or standard output. This script output is equivalent to the plain text output format of pg_dump. Some of the options controlling the output are therefore analogous to pg_dump options.

		Obviously, pg_restore cannot restore information that is not present in the archive file. For instance, if the archive was made using the "dump data as INSERT commands" option, pg_restore will not be able to load the data using COPY statements.
		
		To restore the custom file format, use the following command:

			pg_restore -d database_name database.dump

		Using the -j option, you can dramatically reduce the time to restore a large database to a server running on a multiprocessor machine. This is achieved by running the most time-consuming parts of pg_restore, namely, those that load data, create constraints, or create indices using multiple simultaneous tasks. Each job represents one thread or one process; it uses a separate connection to the server and depends on the operating system. For example, this command will restore a database in four concurrent jobs:

			pg_restore -j 4 -d database_name database.dump
			
		Use the following to drop the database and recreate it from the dump:

			dropdb database_name  pg_restore -C -d database_name database.dump
			With the -C option, data is always restored to the database name that appears in the dump file.

		Run the following to reload the dump into a new database:
			createdb -T template0 database_name  pg_restore -d database_name database.dump
			
==================================================			
-----How to backup database object definitions----
==================================================

		From time to time, there is a need to backup only the database object definitions, which allows you to restore the schema only. It can be useful in the test phase, in which you do not want to keep the old test data populated.

		Use the following command to backup all objects in all databases, including roles, databases, tablespaces, tables, schemas, indexes, functions, triggers, constraints, privileges, views, and ownerships:

			pg_dumpall --schema-only > definitions.sql

		Use the following command to backup the role definition only:

			pg_dumpall --roles-only > roles.sql

		Use the following command to backup the tablespaces definition:

			pg_dumpall --tablespaces-only > tablespaces.sql
			
			
			
===============================================================================			
------pg_basebackup simple backup can be taken using the following syntax------
===============================================================================		

	Tar and Compressed Format

			pg_basebackup -h localhost -p 5432 -U postgres -D /backupdir/latest_backup -Ft -z -Xs -P
 
	Plain Format

			pg_basebackup -h localhost -p 5432 -U postgres -D /backupdir/latest_backup -Fp -Xs -P
			
			
===============================================================================			
---------------------------   pg_basebackup PITR    --------------------------
===============================================================================				
			
	https://dbsguru.com/pitr-pg_basebackup-in-postgresql/   <PITR>
	
	https://www.percona.com/blog/2018/12/21/backup-restore-postgresql-cluster-multiple-tablespaces-using-pg_basebackup/
	https://www.digitalocean.com/community/tutorials/how-to-set-up-continuous-archiving-and-perform-point-in-time-recovery-with-postgresql-12-on-ubuntu-20-04