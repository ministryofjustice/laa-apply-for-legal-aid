# LAA apply for legal aid

This is the service api for persisting application related information to the back end database and
may well be used to fire requests to other services.

* Ruby version 
    * Ruby version 2.5.1
    * Rails 5


* System dependencies
    * postgres 10.5  -> see setup below

* Configuration
    you may have to install postgres gem if you dont already have it 
    
    ```brew install libpq ```                                         # needed for the pg gem's native extensions
   
    ```PATH=$PATH:/usr/local/opt/libpq/bin```        # so that the pg gem can find the pq library
    
    ```gem install pg```
    
    ```rbenv rehash```
    
    * ```bundle install```


* How to run the test suite
    * ```bundle exec rspec spec```

* Services (job queues, cache servers, search engines, etc.)
    

* Deployment instructions
    * check the code out and run ```rails s```

* play with application
    Once the server is started you can actualy use postman to fire requests using the endpoints below
    

* Developer local Endpoints
    * ``http://localhost:3000/api/v1/applications``
        * Only POST is supported at the moment so this wil create an application and retrun application ref
    * ``http://localhost:3000/api/v1/status``
        * Only GET is supported at the moment not sure anything else is needed here


## Docker

The docker file is created against a ruby alpine image using version 2.5.1 which is consistent
with the latest version at the time of writing.

Alpine images are usually very lightweight and such are preferred choice for deploying containers.

In order to create a local build you can run

```docker build -t laa-apply-for-legalaid-api .```


And then run the image using

```docker container run  -d -p 3000:3000 laa-apply-for-legalaid-api```


## Postgres Sql

If you already have an installation of postgres you might want to use it.
For development mode i am going for the simplest setup without setting any specific roles or users

If you dont have postgres installed then you can run the following command to get up and running quickly

```docker run  -d -v pg-data:/var/lib/postgresql/data -p 5432:5432  --name postgres  postgres:10.5```
 
 the 10.5 version appears to be the latest and most likely the one we will be using in RDS.
 
 The above will start a postgres server and expose it on ```localhost:5432```
 
 
 If you are running this for the first time you will have to run the following commands form within the project
 
 ```rake db:setup```
 
 ```rake db:migrate```
 
 
For every other time you do a pull it might be a good idea to 
```rake db:migrate```

It's also good idea at this pint to rerun the tests.

```bundle exec rspec spec```

If all is well the tests will now work with postgres database
The tests will create a test schema and delete the data  once its done.
