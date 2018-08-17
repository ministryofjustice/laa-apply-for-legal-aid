# LAA apply for legal aid

This is the service api for persisting application related information to the back end database and
may well be used to fire requests to other services.

## Setting up development environment

### Ruby version

* Ruby version 2.5.1
* Rails 5

For [rbenv](https://github.com/rbenv/rbenv) users:

```
rbenv install $(cat .ruby-version)
```

### System dependencies

* Postgresql 10.5

```
brew install postgres
```

### Setup

Install gems, set environment files and setup database.

```
# From the root of the project execute the following command:
bin/setup
```

### Run the application server

```
bin/rails s
```

### Available API endpoints

Once the server is started you can actualy use postman to fire requests using the endpoints below:

```
bundle exec rake routes | grep v1_
```

## Testing

How to run the test suite:

```
bundle exec rspec
```

## Docker

The docker file is created against a ruby alpine image using version 2.5.1 which is consistent
with the latest version at the time of writing.

Alpine images are usually very lightweight and such are preferred choice for deploying containers.

In order to create a local build you can run

```
docker build -t laa-apply-for-legalaid-api .
```

And then run the image using

```
docker container run  -d -p 3000:3000 laa-apply-for-legalaid-api
```

## Troubleshooting

### Postgresql

If you already have an installation of postgres you might want to use it.
For development mode i am going for the simplest setup without setting any specific roles or users

If you dont have postgres installed then you can run the following command to get up and running quickly

```
docker run  -d -v pg-data:/var/lib/postgresql/data -p 5432:5432  --name postgres  postgres:10.5
```

the 10.5 version appears to be the latest and most likely the one we will be using in RDS.

The above will start a postgres server and expose it on ```localhost:5432```

If you are running this for the first time you will have to run the following commands form within the project

```
rake db:setup
rake db:migrate
```

For every other time you do a pull it might be a good idea to

```
rake db:migrate
```

It's also good idea at this pint to rerun the tests.

```
bundle exec rspec
```

If all is well the tests will now work with postgres database
The tests will create a test schema and delete the data  once its done.
