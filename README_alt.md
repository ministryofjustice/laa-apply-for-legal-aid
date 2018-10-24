An alternative setup option exists using the makefile, which can be used by following the steps below:

## Initial setup

Run ```make initial-setup```

This will create the db schema  and run a  migration. you shouldn't have to run this again.

## Running the tests

In order to run the tests run


 * ```./bin/rake```

 This runs rubocop and the specs. You can also run ```make test``` which builds a docker image and runs this inside it, but it takes longer.

 * ```make test```

 This is currently setup to run all rspec tests and will run them in docker containers, which means
 it will take longer to run.


## Running the application

 * ```make serve```

 This will use docker compose to start postgres and the api project.
 requests will be served on port localhost:3000


## Other options

There are other configurations in the makefile which you can use if you want

i.e. ```start-local-server```

This will start a server without docker and setup a postgres db exposed at localhost:5432.
Benefit of this is you dont have to build container everytime you make a change to a file.  handy for the html/css changes.
