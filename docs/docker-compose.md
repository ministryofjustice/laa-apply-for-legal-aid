# Docker compose

## Setup

- add `.env.docker-compose` at the root of the app
- copy the contents of `.env.sample` or an existing `.env.development` to it
- amend the secrets as necessary
- preppend the following env vars to the `.env.docker-compose`

```
SECRET_KEY_BASE=just-for-local-docker-compose
RAILS_SERVE_STATIC_FILES=only-presence-required

# docker composes postgres image details ("database" is the name we give the service in the docker compose file. It can be changed to foobar, as long as it is done in both places)
DATABASE_URL=postgresql://postgres@database/laa-apply-for-legalaid
POSTGRES_HOST=database
POSTGRES_PORT=5432
POSTGRES_USER=postgres

# docker composes redis image details ("cache" is the name we give the service in the docker compose file. It can be changed to foobar, as long as it is done in both places)
REDIS_HOST=cache
REDIS_PROTOCOL=redis
REDIS_PORT=6379
REDIS_PASSWORD=

# docker compose dummy vars for AWS S3 connection. Required to prevent errors on startup
AWS_ACCESS_KEY_ID=dummy
AWS_SECRET_ACCESS_KEY=dummy
AWS_REGION=eu-west-2
S3_BUCKET="local-bucket"
```
*These are required to emulate a deployed environment*

## Running

- [re]build docker image
```sh
docker compose down --volumes --remove-orphans && docker compose build --no-cache --progress=plain
```

- switch off clamav used by development*
```sh
sudo launchctl unload /Library/LaunchDaemons/clamav.clamd.plist
```
*\*because it will suffer a port clash with the compose image used*

- run docker image
```sh
docker compose up
```



