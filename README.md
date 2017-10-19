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

## How to Run

This is a [Rails v5.1.4][rails] application that requires:

- [Ruby v2.3.5][ruby]
- [PostgreSQL >= v9.6][postgres]
- [Docker >= 17.05][docker]

For portability, you may use [Docker][docker] to containerize all dependencies
and run it. Otherwise, you can run the app locally by running:

- `bin/setup`
- `bin/rails server`

## How to Test

The test suite uses [RSpec][rspec] and can be run using `bin/rake`.

[docker]:   https://docker.com
[rspec]:    https://rspec.info
[rails]:    https://rubyonrails.org
[ruby]:     https://www.ruby-lang.org
[postgres]: https://www.postgresql.org
