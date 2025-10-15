#
# Copyright (C) 2025 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

VERSION ?= 1.0.0-dev
CONTAINER_MANAGER ?= podman

# Image configuration
IMAGE_REPO ?= quay.io/redhat-aipcc/claudio
IMAGE_TAG ?= v${VERSION}
IMAGE_NAME ?= $(IMAGE_REPO):$(IMAGE_TAG)
IMAGE_SOURCE_TAG ?= $(IMAGE_TAG)

# Artifact naming
ARTIFACT_NAME ?= claudio

# Build actions
.PHONY: oci-build oci-save oci-load oci-push-arch oci-manifest-build oci-manifest-push oci-tag oci-push

oci-build:
	${CONTAINER_MANAGER} build -t $(IMAGE_NAME) .

oci-save:
	${CONTAINER_MANAGER} save -m -o $(ARTIFACT_NAME).tar $(IMAGE_NAME)

oci-load:
	${CONTAINER_MANAGER} load -i $(ARTIFACT_NAME)-amd64/$(ARTIFACT_NAME)-amd64.tar
	${CONTAINER_MANAGER} load -i $(ARTIFACT_NAME)-arm64/$(ARTIFACT_NAME)-arm64.tar

oci-push-arch:
	${CONTAINER_MANAGER} push $(IMAGE_REPO):$(IMAGE_TAG)-amd64
	${CONTAINER_MANAGER} push $(IMAGE_REPO):$(IMAGE_TAG)-arm64

oci-manifest-build:
	${CONTAINER_MANAGER} manifest rm $(IMAGE_NAME) || true
	${CONTAINER_MANAGER} manifest create $(IMAGE_NAME)
	${CONTAINER_MANAGER} manifest add $(IMAGE_NAME) docker://$(IMAGE_REPO):$(IMAGE_SOURCE_TAG)-amd64
	${CONTAINER_MANAGER} manifest add $(IMAGE_NAME) docker://$(IMAGE_REPO):$(IMAGE_SOURCE_TAG)-arm64

oci-manifest-push:
	${CONTAINER_MANAGER} manifest push $(IMAGE_NAME)

oci-tag:
	${CONTAINER_MANAGER} tag $(IMAGE_REPO):$(IMAGE_SOURCE_TAG) $(IMAGE_NAME)

oci-push:
	${CONTAINER_MANAGER} push $(IMAGE_NAME)
