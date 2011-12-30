BUNDLE=$(shell test -d ./vendor/bundle && echo bundle exec)
check:
#	rake test
	$(BUNDLE) rspec spec --drb --color

PHONY: check
