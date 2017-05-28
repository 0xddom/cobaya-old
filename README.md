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

When hacking on this gem, the REPL `pry` comes in handy. You can load the
contents of the gem with `pry --gem`.

To test the CLI, run

    ruby -Ilib bin/cobaya

