.PHONY: test

fix-lint:
	mix format
lint:
	mix format --check-formatted
test:
	mix test