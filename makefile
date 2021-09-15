define envCheck
	@if [ -z "$${$(1)}" ]; then \
		echo "Missing required environment variable $(1)" 1>&2; \
		exit 1; \
	fi
endef

.PHONY: nothing
nothing:
	# Do nothing

.PHONY: docs
docs:
	@./gradlew dokkaHtml dokkaJavadoc

.PHONY: github-release
github-release: verify-github-env patch-version prep-github-gpg
	@echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
	@echo "#"
	@echo "# Publishing artifacts"
	@echo "#"
	@echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
	@echo
	@./gradlew \
		-Pnexus.user=${NEXUS_USER} \
		-Pnexus.pass=${NEXUS_PASS} \
		-Psigning.gnupg.executable=gpg \
		-Psigning.gnupg.keyName=$(shell gpg --list-secret-keys --keyid-format LONG | grep sec | sed 's#sec \+.\+/\([^ ]\+\).\+#\1#') \
		publish

.PHONY: prep-github-gpg
prep-github-gpg:
	@cat <(echo -e "${GPG_KEY}") | gpg --batch --import

.PHONY: verify-github-env
verify-github-env:
	@echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
	@echo "#"
	@echo "# Verifying GitHub build environment"
	@echo "#"
	@echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
	@echo
	$(call envCheck,NEXUS_USER)
	$(call envCheck,NEXUS_PASS)
	$(call envCheck,GPG_KEY)

.PHONY: patch-version
patch-version:
	@echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
	@echo "#"
	@echo "# Patching build version"
	@echo "#"
	@echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
	@echo
	@sed "s/version \+=.\+/version = \"$(shell echo "${GITHUB_REF}" | sed 's/v//')\"/" build.gradle.kts