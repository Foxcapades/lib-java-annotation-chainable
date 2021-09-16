.PHONY: nothing
nothing:
	# Do nothing

.PHONY: docs
docs:
	@.github/scripts/build.sh doc

.PHONY: github-release
github-release:
	@.github/scripts/build.sh github-release

