define envCheck
@if [ -z "$${$(1)}" ]; then \
	echo "Missing required environment variable $(1)" 1>&2; \
	exit 1; \
fi
endef

define gitTag
$(shell echo "${GITHUB_REF}" | cut -d/ -f3 | sed -e "s#v##")
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
		-Pnexus.user="${NEXUS_USER}" \
		-Pnexus.pass="${NEXUS_PASS}" \
		-Psigning.gnupg.executable=gpg \
		-Psigning.gnupg.keyName="$(shell gpg --list-secret-keys --keyid-format LONG | grep sec | sed -e 's#sec \+.\+/\([^ ]\+\).\+#\1#')" \
		publish

.PHONY: prep-github-gpg
prep-github-gpg: verify-github-env
	$(shell cat <(echo -e "${GPG_KEY}") | gpg --batch --import)
	@echo "Done"
	@echo

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
	$(call envCheck,GITHUB_REF)
	@echo "Ok"
	@echo

.PHONY: patch-version
patch-version: verify-github-env
	@echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
	@echo "#"
	@echo "# Patching build version"
	@echo "#"
	@echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #"
	@echo
	@sed -i "s#version \+=.\+#version = \"$(call gitTag)\"#" build.gradle.kts
	@echo "Done"
	@echo
