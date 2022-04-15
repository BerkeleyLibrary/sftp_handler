# GOBI Processor
A command-line tool for retrieving GOBI order marc files (.ord) via sftp. Default remote directory is gobiord and local directory is data.

## Building the app

```sh
docker-compose build
```

## Running it locally

Look for todays Gobi order file will be name eboo{mmdd}.ord on the gobi server in the gobiord directory.
File by default will go into /opt/app/data directory

```sh
docker-compose up 
```

Look for a specific file

```sh
docker-compose run --rm gobi_sftp ebook0413.ord 
```

Look for a specific file with command line arguments

```sh
docker-compose run --rm gobi_sftp ebook0413.ord --remote_dir gobiord local_dir path_to_local_dir
```


## Running it in production

Standard way this should be set to run each day to look for a file if it exists

```sh
docker run --rm gobi_sftp --local_dir '/path_to_local_dir' 
```

Example if you wanted to specify a specific remote directory as well

```sh
docker run --rm gobi_sftp ebook0312.ord --remote_dir remote_directory --local_dir '/path_to_local_dir' 
```
