.PHONY: test

run:
	iex -S mix
fix-lint:
	mix format
lint:
	mix format --check-formatted
test:
	mix test
publish:
	mix hex.publish