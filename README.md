# Docker container for MySQL 8.4 LTS + DataJoint

## Features
- [MySQL 8.4 LTS](https://dev.mysql.com/blog-archive/introducing-mysql-innovation-and-long-term-support-lts-versions/) for long-term stability and performance.
- Preconfigured settings tailored for [DataJoint](https://github.com/datajoint).
- Preconfigured for MySQL replication

## Usage
1) Clone repository
2) Create `.env` file with at least this variable: `MYSQL_ROOT_PASSWORD=CHANGE_ME__CHANGE_ME`
3) `docker compose up -d`
4) Connect to database for administration: `mysql -u root -h localhost -P 3306 -p`

## Replication
[See here for detailed MySQL replication setup guide](https://dev.mysql.com/doc/refman/8.4/en/replication-gtids-howto.html)

1) config has to contain:
   ```
   server_id   = 51  # set to invidiual ID for each MySQL server instance
   
   skip_replica_start = ON
   gtid_mode = ON
   enforce_gtid_consistency = ON
   ```
2) set replication source
- connect to database with mysql client as shows above in `Usage`

```sql
mysql> CHANGE REPLICATION SOURCE TO
     >     SOURCE_HOST = "host",
     >     SOURCE_PORT = port,
     >     SOURCE_USER = "user",
     >     SOURCE_PASSWORD = "password",
     >     SOURCE_AUTO_POSITION = 1;
```

> Note: Additional options necessary to set up SSL for replication connections

3) start replica
- connect to database with mysql client as shows above in `Usage`

```sql
mysql> START REPLICA;
```

4) confirm that databases/tables exist on replica
- connect to database with mysql client as shows above in `Usage`

```sql
SHOW DATABASES;
USE database_name;
SHOW TABLES;
```


## Attribution
- optional `entrypoint-monitor-config.sh` script adapted from [`datajoint/mysql-docker`](https://hub.docker.com/r/datajoint/mysql)


## Links
- [MySQL/Release History](https://en.wikipedia.org/wiki/MySQL#Release_history)
- [replication options GTIDs](https://dev.mysql.com/doc/refman/8.0/en/replication-options-gtids.html)
- [replication options replica](https://dev.mysql.com/doc/refman/8.4/en/replication-options-replica.html)
- [MySQL SSL cipher](https://dev.mysql.com/doc/refman/8.4/en/server-system-variables.html#sysvar_ssl_cipher)
- [Replication SSL](https://dev.mysql.com/doc/refman/8.4/en/replication-encrypted-connections.html)
- [mysql 8.4 dockerfile](https://github.com/docker-library/mysql/tree/master/8.4)
- [mysql docker hub](https://hub.docker.com/_/mysql)
- [datajoint/mysql](https://hub.docker.com/r/datajoint/mysql/tags)
  
