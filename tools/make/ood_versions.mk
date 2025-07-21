# Default OOD version if not specified externally
OOD_VERSION ?= 3.1.7

OOD_UID := $(shell id -u)
OOD_GID := $(shell id -g)

# Configuration for OOD 4.0.6
define CONFIG_4.0.6
OOD_IMAGE := hmdc/sid-ood:ood-4.0.6.el8
RUBY_VERSION := ruby:3.3
NODE_VERSION := nodejs:20
LOOP_BUILDER_IMAGE := hmdc/ondemand-loop:builder-R3.3
endef

# Configuration for OOD 4.0.0
define CONFIG_4.0.0
OOD_IMAGE := hmdc/sid-ood:ood-4.0.0.el8
RUBY_VERSION := ruby:3.3
NODE_VERSION := nodejs:20
LOOP_BUILDER_IMAGE := hmdc/ondemand-loop:builder-R3.3
endef

# Configuration for OOD 3.1.14
define CONFIG_3.1.14
OOD_IMAGE := hmdc/sid-ood:ood-3.1.14.el8
RUBY_VERSION := ruby:3.1
NODE_VERSION := nodejs:18
LOOP_BUILDER_IMAGE := hmdc/ondemand-loop:builder-R3.1
endef

# Configuration for OOD 3.1.7
define CONFIG_3.1.7
OOD_IMAGE := hmdc/sid-ood:ood-3.1.7.el8
RUBY_VERSION := ruby:3.1
NODE_VERSION := nodejs:18
LOOP_BUILDER_IMAGE := hmdc/ondemand-loop:builder-R3.1
endef

# Load the selected configuration
CONFIG_VAR := CONFIG_$(OOD_VERSION)
$(eval $(call $(CONFIG_VAR)))
