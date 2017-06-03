BE=bundle exec
BI=bundle install

.PHONY: install dist lint

install:
	$(BI)

lint:
	$(BE) rubycritic --no-browser -f html lib/cobaya
