.DEFAULT_GOAL := help

.PHONY: translations
translations:
	python -m django makemessages -a -i "../frontend/node_modules"

.PHONY: compile-translations
compile-translations:
	python -m django compilemessages

.PHONY: help
help:
	@grep -E '^[.a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort -k 1,1 | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
