# LAA apply for legal aid

This is the service api for persisting application related information to the back end database and
may well be used to fire requests to other services.

* Ruby version 
    * Ruby version 2.5.1
    * Rails 5


* System dependencies
    * postgres 10.5  -> see setup below

* Configuration
   
    ```brew install postgres```
    
    ```bundle install```



## Initial setup

Run ```make initial-setup```

This will create the db schema  and run a  migration. you shouldn't have to run this again.

## Running the tests

In order to run the tests run

 * ```make test```
 
 This is currently setup to run all rspec tests

## Running the application

 * ```make serve```
 
 This will use docker compose to start postgres and the api project.
 requests will be served on port localhost:3000
 

## Other options

There are other configurations in the makefile which you can use if you want 

i.e. ```start-local-server```

This will start a server without docker and setup a postgres db exposed at localhost:5432.  
Benefit of this is you dont have to build container everytime you make a change to a file.  handy for the html/css changes.



## Developer local Endpoints

* Post an application 

```http://localhost:3000/v1/applications```    

* Get status of the service 

```http://localhost:3000/v1/status```

        
        

    
 
   