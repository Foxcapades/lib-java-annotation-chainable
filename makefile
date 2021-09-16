.PHONY: nothing
nothing:
	# Do nothing

.PHONY: docs
docs:
	@bash .github/scripts/bash.sh doc

.PHONY: github-release
github-release:
	@bash .github/scripts/bash.sh github-release
