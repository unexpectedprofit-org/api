install-deps:
	bundle install --path vendor

migrate:
ifdef VERSION
	bundle exec sequel -m migrations -M $(VERSION) sqlite://db.sqlite
else
	bundle exec sequel -m migrations sqlite://db.sqlite
endif

run:
	rerun -- bundle exec rackup -Ilib
