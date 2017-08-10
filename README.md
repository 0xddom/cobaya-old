cobaya
=================

A genetic programming fuzzer to fuzz ruby interpreters

## Setup

1. Install `gem install cobaya`.

## Usage

### Mutation

To mutate a sample run the following command:

    cobaya mutate <file>
	
The seed can be especified with the `-s` option. If not specified, 0 is used

## Development

### Running the test suite

To run the test suite run the following commands

    bundle install
	bundle exec rspec
	
### Build the documentation

The rdoc documentation can be built with

    bundle install
	bundle exec rake rdoc
	
The user manual can be build with the following command after installing node.js and npm

    cd manual
	gitbook build

