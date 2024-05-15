# Backup Container Databases

This project is based on the [docker-db-backup](https://github.com/tiredofit/docker-db-backup) project that allows you to backup databases from different containers and store them in external storage (e.g. S3).

This repository contains a ready-to-use configuration (docker-compose) for backing up databases from a container and storing them in an S3 bucket.

It also includes a more advanced `restore` script file that uses the default `docker-db-backup` restore script and adds some extra features for restoring the database from the S3 bucket.

## Usage

1. Copy the `environment/backup.env.example` file to `environment/backup.env` and adjust the variables to your needs.

2. The `docker-compose.yml` file contains a default database container (PostgreSQL) that will be backed up. You can remove it if you don't need it. It is only used for testing purposes.

3. Run the container with the following command:

```bash
docker compose up -d
```

## Restore

The `restore-s3.sh` script file is used to restore the database from the S3 bucket. It uses the `docker-db-backup` restore script and adds some extra features for restoring the database from the S3 bucket.

This file is mounted inside the backup container and can be executed from the container shell.

To restore the database, you need to run the following command:

```bash
docker exec -it backup /restore-s3.sh
```

An interactive shell will be opened, and you will be asked to provide the backup file to restore. The script will download the backup file from the S3 bucket and restore the database.