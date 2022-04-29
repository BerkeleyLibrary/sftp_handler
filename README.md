# GOBI Processor

A command-line tool for retrieving GOBI order marc files (.ord) via sftp.

## Running it locally

To run the application for real, you'll need to configure a local `.env` file with the GOBI password, which you can obtain from LastPass (search for "gobi"). Don't worry: this file is git-ignored.

```ini
# ./.env (in the directory you cloned this from GitLab)
GOBI_PASS=password-from-lastpass
```

---

> **Additional Configuration:** The app accepts a few other configuration options, which you can see in `config/connections.yml`. The default values should work fine, however, so you probably don't need to change them. Also note that everything is mocked in the rspec tests, where you're not actually hitting the GOBI server.

---

With that configured, you can run the application like so:

```sh
docker compose build # as always, you need to build it first
docker compose run --rm app ebook0413.ord
```

Today's GOBI order file will be at `/gobiord/eboo{mmdd}.ord` on their server. By default, the app copies it into the `/opt/app/data` directory within the container (mapped to `./data` in development), but this can be overwritten by the `--local_dir` flag:

```sh
docker compose run --rm app --local_dir /path/in/container
```

Look for a specific file by passing its name as an argument:

```sh
docker-compose run --rm app ebook0413.ord
```

You can also pass additional arguments when looking for a specific file:

```sh
docker-compose run --rm app ebook0413.ord \
    --remote_dir gobiord-staging \
    --local_dir path_to_local_dir
```

## Testing

The app includes a number of RSpec tests integrated into its Jenkins pipeline. You can run the tests locally via:

```sh
docker compose run --rm --entrypoint=rspec app
```

Or by shelling into the container and running RSpec from there:

```sh
docker compose run --rm --entrypoint=sh app
rspec
```

---

> **Insecure KEX:** As of 04/28/22, Gobi's server only supports outdated Diffie-Hellman key exchange algorithms, which you local sftp client will probably (and correctly) refuse. If you want to test manually, then for now you must explicitly allow the old algorithm by passing the following option to your sftp client: `-oKexAlgorithms=+diffie-hellman-group1-sha1`.

---

## Production configuration

In production, the app must copy the files to a place accessible to Alma, which is configured to pull them daily at 9PM. As of 04/28/22, this was decided to be the `gobi-ebook-eocr` directory in the `alma` NetApp volume.
