.PHONY: help
.DEFAULT_GOAL := help
RUN := $(shell realpath $(shell dirname $(firstword $(MAKEFILE_LIST)))/../scripts/run2.sh)

export USE_CONTAINER ?= docker

# Begin OS detection
ifeq ($(OS),Windows_NT) # is Windows_NT on XP, 2000, 7, Vista, 10...
    export OPERATING_SYSTEM := Windows
    export DEFAULT_FEATURES = default-msvc
else
    export OPERATING_SYSTEM := $(shell uname)  # same as "uname -s"
    export DEFAULT_FEATURES = default
endif

help:
	@echo "                                      __   __  __"
	@echo "                                      \ \ / / / /"
	@echo "                                       \ V / / / "
	@echo "                                        \_/  \/  "
	@echo ""
	@echo "                                      V E C T O R"
	@echo ""
	@echo "---------------------------------------------------------------------------------------"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Default

all: check build-all package-all test-docker test-behavior verify ## run all tests, checks, and verifications

##@ Building

build: ## build a project binary
	$(RUN) build

build-all: build-x86_64-unknown-linux-musl build-armv7-unknown-linux-musleabihf build-aarch64-unknown-linux-musl ## build the project in debug mode for all platforms

build-x86_64-unknown-linux-musl: ## build the project for the x86_64 architecture
	$(RUN) build-x86_64-unknown-linux-musl

build-armv7-unknown-linux-musleabihf: load-qemu-binfmt ## build the project for the armv7 architecture
	$(RUN) build-armv7-unknown-linux-musleabihf

build-aarch64-unknown-linux-musl: load-qemu-binfmt ## build the project for the aarch64 architecture
	$(RUN) build-aarch64-unknown-linux-musl

##@ Developing

bench: build ## run benchmarks
	$(RUN) bench

test: test-behavior test-integration test-unit ## Runs all tests, unit, bheaviorial, and integration.

test-behavior: build ## Runs behaviorial tests
	$(RUN) test-behavior

test-integration: ## Runs all integration tests
	$(RUN) test-integration

test-integration-aws: ## Runs Clickhouse integration tests
	$(RUN) test-integration-aws

test-integration-clickhouse: ## Runs Clickhouse integration tests
	$(RUN) test-integration-clickhouse

test-integration-docker: ## Runs Docker integration tests
	$(RUN) test-integration-docker

test-integration-elasticsearch: ## Runs Elasticsearch integration tests
	$(RUN) test-integration-elasticsearch

test-integration-gcp: ## Runs GCP integration tests
	$(RUN) test-integration-gcp

test-integration-influxdb: ## Runs Kafka integration tests
	$(RUN) test-integration-influxdb

test-integration-kafka: ## Runs Kafka integration tests
	$(RUN) test-integration-kafka

test-integration-kubernetes: ## Runs Kubernetes integration tests
	$(RUN) test-integration-kubernetes

test-integration-loki: ## Runs Loki integration tests
	$(RUN) test-integration-loki

test-integration-pulsar: ## Runs Kafka integration tests
	$(RUN) test-integration-pulsar

test-integration-splunk: ## Runs Kafka integration tests
	$(RUN) test-integration-splunk

test-integration-kubernetes: build-x86_64-unknown-linux-musl ## Runs Kubernetes integration tests
	$(RUN) test-integration-kubernetes

test-unit: ## Runs unit tests, tests which do not require additional services to be present
	$(RUN) test-unit

##@ Checking

check: check-all ## default target, check everything

check-all: check-code check-fmt check-style check-markdown check-generate check-blog check-version check-examples check-component-features ## check everything

check-code: ## check code
	$(RUN) check-code

check-component-features: ## check that all component features are setup properly
	$(RUN) check-component-features

check-fmt: ## check that all files are formatted properly
	$(RUN) check-fmt

check-style: ## check that all files are styled properly
	$(RUN) check-style

check-markdown: ## check that markdown is styled properly
	$(RUN) check-markdown

check-generate: ## check that no files are pending generation
	$(RUN) check-generate

check-version: ## check that Vector's version is correct accounting for recent changes
	$(RUN) check-version

check-examples: build ## check that the config/exmaples files are valid
	$(RUN) check-examples

check-blog: ## check that all blog posts are signed and valid
	$(RUN) check-blog

##@ Packaging

package-all: package-archive-all package-deb-all package-rpm-all ## package everything

package-archive: build ## package the Vector archive
	$(RUN) package-archive

package-archive-all: package-archive-x86_64-unknown-linux-musl package-archive-armv7-unknown-linux-musleabihf package-archive-aarch64-unknown-linux-musl ## package all archives

package-archive-x86_64-unknown-linux-musl: build-x86_64-unknown-linux-musl ## package the x86_64 archive
	$(RUN) package-archive-x86_64-unknown-linux-musl

package-archive-armv7-unknown-linux-musleabihf: build-armv7-unknown-linux-musleabihf ## package the armv7 archive
	$(RUN) package-archive-armv7-unknown-linux-musleabihf

package-archive-aarch64-unknown-linux-musl: build-aarch64-unknown-linux-musl ## package the aarch64 archive
	$(RUN) package-archive-aarch64-unknown-linux-musl

package-deb: ## build the x86_64 deb package
	$(RUN) package-deb

package-deb-all: package-deb-x86_64 package-deb-armv7 package-deb-aarch64 ## build all deb packages

package-deb-x86_64: package-archive-x86_64-unknown-linux-musl ## build the x86_64 deb package
	$(RUN) package-deb-x86_64

package-deb-armv7: package-archive-armv7-unknown-linux-musleabihf ## build the armv7 deb package
	$(RUN) package-deb-armv7

package-deb-aarch64: package-archive-aarch64-unknown-linux-musl  ## build the aarch64 deb package
	$(RUN) package-deb-aarch64

package-rpm: ## default target, build the x86_64 rpm package
	$(RUN) package-rpm

package-rpm-all: package-rpm-x86_64 package-rpm-armv7 package-rpm-aarch64 ## build all rpm packages

package-rpm-x86_64: package-archive-x86_64-unknown-linux-musl ## build the x86_64 rpm package
	$(RUN) package-rpm-x86_64

package-rpm-armv7: package-archive-armv7-unknown-linux-musleabihf ## build the armv7 rpm package
	$(RUN) package-rpm-armv7

package-rpm-aarch64: package-archive-aarch64-unknown-linux-musl ## build the aarch64 rpm package
	$(RUN) package-rpm-aarch64

##@ Releasing

release: ## Release a new Vector version
	@$(MAKE) release-prepare
	@$(MAKE) generate CHECK_URLS=false
	@$(MAKE) release-commit

release-commit: ## Commits release changes
	$(RUN) release-commit

release-docker: ## Release to Docker Hub
	$(RUN) release-docker

release-github: ## Release to Github
	$(RUN) release-github

release-homebrew: ## Release to timberio Homebrew tap
	$(RUN) release-homebrew

release-prepare: ## Prepares the release with metadata and highlights
	$(RUN) release-prepare

release-push: ## Push new Vector version
	$(RUN) release-push

release-rollback:
	$(RUN) release-rollback

release-s3: ## Release artifacts to S3
	$(RUN) release-s3

sync-install:
	@aws s3 cp distribution/install.sh s3://sh.vector.dev --sse --acl public-read

##@ Verifying

verify: verify-rpm verify-deb ## default target, verify all packages

verify-rpm: verify-rpm-amazonlinux-1 verify-rpm-amazonlinux-2 verify-rpm-centos-7 ## verify all rpm packages

verify-rpm-amazonlinux-1: package-rpm-x86_64 ## verify the rpm package on Amazon Linux 1
	$(RUN) verify-rpm-amazonlinux-1

verify-rpm-amazonlinux-2: package-rpm-x86_64 ## verify the rpm package on Amazon Linux 2
	$(RUN) verify-rpm-amazonlinux-2

verify-rpm-centos-7: package-rpm-x86_64 ## verify the rpm package on CentOS 7
	$(RUN) verify-rpm-centos-7

verify-deb: verify-deb-artifact-on-deb-8 verify-deb-artifact-on-deb-9 verify-deb-artifact-on-deb-10 verify-deb-artifact-on-ubuntu-16-04 verify-deb-artifact-on-ubuntu-18-04 verify-deb-artifact-on-ubuntu-19-04 ## verify all deb packages

verify-deb-artifact-on-deb-8: package-deb-x86_64 ## verify the deb package on Debian 8
	$(RUN) verify-deb-artifact-on-deb-8

verify-deb-artifact-on-deb-9: package-deb-x86_64 ## verify the deb package on Debian 9
	$(RUN) verify-deb-artifact-on-deb-9

verify-deb-artifact-on-deb-10: package-deb-x86_64 ## verify the deb package on Debian 10
	$(RUN) verify-deb-artifact-on-deb-10

verify-deb-artifact-on-ubuntu-16-04: package-deb-x86_64 ## verify the deb package on Ubuntu 16.04
	$(RUN) verify-deb-artifact-on-ubuntu-16-04

verify-deb-artifact-on-ubuntu-18-04: package-deb-x86_64 ## verify the deb package on Ubuntu 18.04
	$(RUN) verify-deb-artifact-on-ubuntu-18-04

verify-deb-artifact-on-ubuntu-19-04: package-deb-x86_64 ## verify the deb package on Ubuntu 19.04
	$(RUN) verify-deb-artifact-on-ubuntu-19-04

verify-nixos:  ## verify that Vector can be built on NixOS
	$(RUN) verify-nixos

##@ Website

generate:  ## Generates files across the repo using the data in /.meta
	$(RUN) generate

export ARTICLE ?= true
sign-blog: ## Sign newly added blog articles using GPG
	$(RUN) sign-blog

##@ Utility

clean: ## clean everything
	$(RUN) clean

fmt: ## Format code
	$(RUN) fmt

init-target-dir: ## create target directory owned by the current user
	$(RUN) init-target-dir

load-qemu-binfmt: ## load `binfmt-misc` kernel module which required to use `qemu-user`
	$(RUN) load-qemu-binfmt

signoff: ## Signsoff all previous commits since branch creation
	$(RUN) signoff

slim-builds: ## Updates the Cargo config to product disk optimized builds, useful for CI
	$(RUN) slim-builds

target-graph: ## display dependencies between targets in this Makefile
	@cd $(shell realpath $(shell dirname $(firstword $(MAKEFILE_LIST))))/.. && docker-compose run --rm target-graph $(TARGET)

version: ## Get the current Vector version
	$(RUN) version