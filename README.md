Newborn Screening Data on FHIR
==============================

## Background

The Utah Newborn Screening Program collects a variety of demographic data from
the screening specimen that is sent in for a newborn. Often the data collected
is missing or inaccurate. In order to complete the data and/or ensure accuracy,
the Utah Newborn Screening Program compares this data against the Utah Office of
Vital Records and Statistics data from birth and death certificates. The current
process is antiquated and would benefit from the usage of a newer technology
like FHIR.

This application provides an FHIR interface to compare the data between the Utah
Newborn Screening Program and the Utah Office of Vital Records and Statistics,
including:

- date of birth
- full name
- gestational age
- date of death
- birth weight
- congenital defects
- race
- ethnicity
- gender
- mother's full name
- mother's date of birth

## How To Set Up

Start by copying the contents of `.env.example` into a new file called `.env`.
Make sure that any blank environment variable is filled.

For portability, [Docker][docker] is used alongside [Picobox][picobox] during
development and testing. To set up the application, make sure Docker is
installed and then install Picobox:

    $ gem install picobox
    $ picobox install

Navigate to the project directory and start the Picobox containers:

    $ picobox start

This will spin up a few containers:

- **dev**: the main development container. Most commands will be run through
  here (e.g. starting the servers or adding dependencies).
- **webpack**: a container that runs the [Webpack][webpack] dev server with hot
  module reload.
- **test**: this container runs [RSpec][rspec] for our tests and [Guard][guard].
- **postgres**: the PostgresSQL container that stores the application data. It
  includes a `db-data` volume to persist data during runs.

Once the Picobox containers are running, install the project's Ruby
dependencies:

    $ bundle install

As well as the JavaScript dependencies:

    $ yarn install

Finally, configure the database by running:

    $ rails db:setup


## How To Run

Ensure the Picobox containers are running with:

    $ picobox status

All the containers listed above should be displayed. Otherwise, start the
containers by using Picobox's `start` command.

Now, start the Rails server:

    $ rails s

Then, start the Webpack dev server:

    $ webpack-dev-server

That's it! The application should be live at http://localhost:3000.


## How To Test

The test suite uses [RSpec][rspec] and can be run with:

    $ rspec


## How To Lint

The Ruby linter for this application is [Rubocop][rubocop]. To run it:

    $ bundle exec rubocop


## Dependencies

This is a [Rails v5.1.4][rails] application that requires:

- [Docker ~> 17.05][docker]
- [Ruby ~> 2.4][ruby]
- [Bundler -> 1.15][bundler]
- [Node.js ~> 8.7][node]
- [Yarn ~> 1.2][yarn]
- [PostgreSQL ~> 9.6][postgres]


[docker]:   https://docker.com
[guard]:    https://github.com/guard/guard
[node]:     https://nodejs.org
[picobox]:  https://github.com/surzycki/picobox
[postgres]: https://www.postgresql.org
[rails]:    https://rubyonrails.org
[rspec]:    https://rspec.info
[rubocop]:  http://rubocop.readthedocs.io/en/latest
[ruby]:     https://www.ruby-lang.org
[webpack]:  https://webpack.js.org
[yarn]:     https://yarnpkg.com/en
