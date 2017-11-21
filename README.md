Newborn Screening Data on FHIR
==============================

## Background

The Utah Newborn Screening Program collects a variety of demographic data from
the screening specimen that is sent in for a newborn. Often the data collected
is missing or inaccurate. In order to complete the data and/or ensure accuracy,
the Utah Newborn Screening Program compares this data against the Utah Office of
Vital Records and Statistics data from birth and death certificates. The current
process is antiquated and would benefit from the usage of a newer technology
like FHIR. The full specification can be retrieved [here][reqs].

This application provides an FHIR interface to compare the data between the Utah
Newborn Screening Program and the Utah Office of Vital Records and Statistics.

## How To Run

1. Ensure the correct versions of [Docker][docker] and [Docker Compose][compose]
   are installed per the [dependencies](#dependencies).
2. Run `docker-compose up`.
3. The application is at http://localhost:3000
4. The associated FHIR instance is available at http://localhost:8080

## How To Set Up For Native (Local) Development

1. Ensure all the [dependencies](#dependencies) are installed.
2. Run `bin/setup`.
3. Run `bin/rails server`.

## How To Test

1. Ensure all the [dependencies](#dependencies) are installed.
2. Run `bin/test`.

## Dependencies

This is a [Rails v5.1.4][rails] application that requires:

- [Docker ~> 17.09][docker]
- [Docker Compose ~> 1.17][compose]
- [Ruby ~> 2.4][ruby]
- [Bundler -> 1.15][bundler]
- [Node.js ~> 8.7][node]
- [Yarn ~> 1.2][yarn]
- [PostgreSQL ~> 9.6][postgres]

[bundler]:  https://bundler.io
[compose]:  https://docs.docker.com/compose
[docker]:   https://docker.com
[guard]:    https://github.com/guard/guard
[node]:     https://nodejs.org
[picobox]:  https://github.com/surzycki/picobox
[postgres]: https://www.postgresql.org
[rails]:    https://rubyonrails.org
[reqs]:     http://cs6440.gatech.edu/wp-content/uploads/sites/634/2017/09/38.-CatalogPageCDCUtahJones-Braun.pdf
[rspec]:    https://rspec.info
[rubocop]:  http://rubocop.readthedocs.io/en/latest
[ruby]:     https://www.ruby-lang.org
[webpack]:  https://webpack.js.org
[yarn]:     https://yarnpkg.com/en
