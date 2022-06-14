# SFTP Handler

A command-line tool for SFTP-ing files from different providers. Currently supports LBNL patron files and Gobi E-Order files.

## Getting started

The application is dockerized, so for starters, just build it:

```sh
docker compose build
```

Besides that, it's a fairly standard Ruby library:
- [Thor](https://github.com/rails/thor) for the CLI
- RSpec for testing (along with a few RSpec plugins)

The `bin/berkeley_library-sftp_handler.rb` script is the container's entrypoint, so you can run it ad-hoc like so:

```sh
# view help docs
docker compose run --rm app help
docker compose run --rm app help gobi
docker compose run --rm app help lbnl

# run the gobi loader
docker compose run --rm app gobi
docker compose run --rm app gobi --filename specific-file.ord

# run the lbnl loader
docker compose run --rm app lbnl
docker compose run --rm app lbnl --filename specific-file.zip
```

By default, files are downloaded to `./data`. You can override this with the `--local-dir` option. See the specific help output or the [CLI class](lib/berkeley_library/sftp_handler/cli.rb) for details.

Open a shell (e.g. to run tests) by overriding the entrypoint:

```sh
docker compose run --rm --entrypoint bash app
```

### Secrets and .env

SSH passwords and key data should be stored in the .env file. This file is git-ignored, so don't worry about it being committed. The contents of different secrets will be shared with you via LastPass; just ask for it in Slack.

```ini
LIT_GOBI_PASSWORD="the-password"
LIT_LBNL_KEY_DATA="-----BEGIN RSA PRIVATE KEY-----
...
-----END RSA PRIVATE KEY-----"
```

## Adding new downloaders

To add a new downloader, create a class under BerkeleyLibrary::SftpHandler::Downloader, inherit from Downloader::Base, and implement the `download!` method. Then, integrate it into the CLI by adding a new method to BerkeleyLibrary::SftpHandler::Cli. See the existing examples for Lbnl and Gobi for more guidance.

## Production configuration

In production, the app must copy the files to a place accessible to Alma, which is configured to pull them daily at 9PM. As of 04/28/22, this was decided to be the `gobi-ebook-eocr` directory in the `alma` NetApp volume.
