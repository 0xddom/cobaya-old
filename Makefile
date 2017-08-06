BE=bundle exec
BI=bundle install

.PHONY: install dist lint

install:
	$(BI)

lint:
	$(BE) rubycritic --no-browser -f html lib/cobaya

clean:
	rm -f cov/*
	rm -rf population/*
	rm -rf crashes/*

gem: clean-gem
	gem build cobaya.gemspec

clean-gem:
	rm -f *.gem

fuzz:
	$(BE) cobaya gpfuzz -s 10 ../cobaya-runs/mruby/bin/mruby
