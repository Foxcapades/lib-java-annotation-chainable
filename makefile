.PHONY: nothing
nothing:
	# Do nothing

.PHONY: docs
docs:
	@.github/scripts/bash.sh doc

.PHONY: github-release
github-release:
	@.github/scripts/bash.sh github-release
