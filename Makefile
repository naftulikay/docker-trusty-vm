#!/usr/bin/make -f

IMAGE:=naftulikay/trusty-vm
TAG:=latest

MOUNT_PATH:=/etc/ansible/trusty
LOCAL_FLAGS:=-v $(shell pwd):$(MOUNT_PATH):ro -v $(shell pwd)/ansible.cfg:/etc/ansible/ansible.cfg:ro

# allows us to test SELinux bugs
PRIVILEGED:=true
SELINUX_HOST:=$(shell mountpoint -q /sys/fs/selinux && echo 'true' || echo 'false')

CONTAINER_ID_FILE:=/tmp/container.id
CONTAINER_ID:=$(shell cat "$(CONTAINER_ID_FILE)" 2>/dev/null)

IMAGE_NAME:=$(IMAGE):$(TAG)

# build the docker image
build:
	docker build -t $(IMAGE_NAME) ./

# get status of the vm-like container
status:
	@if [ -z "$(CONTAINER_ID)" ]; then \
		echo "Container Not Running" ; \
		exit 1 ; \
	else \
		echo "Container Running" ; \
	fi

start: build
	@if [ ! -z "$(CONTAINER_ID)" ]; then \
		echo "ERROR: Container Already Running: $(CONTAINER_ID)" >&2 ; \
		exit 1 ; \
	fi
	@# start it
	@echo "Starting the Container: "
	@set -x && docker run -d \
		$$(test "$(PRIVILEGED)" == "true" && echo "--privileged") \
		$(LOCAL_FLAGS) \
		$(IMAGE_NAME) | \
	tee $(CONTAINER_ID_FILE)

stop:
	@if [ -z "$(CONTAINER_ID)" ] && ! docker ps --filter id=$(CONTAINER_ID) --format '{{.ID}}' | grep -qP '.*' ; then \
		echo "ERROR: Container Not Running" >&2 ; \
		rm -f $(CONTAINER_ID_FILE) ; \
		exit 0 ; \
	fi ; \
	docker kill $(CONTAINER_ID) > /dev/null ; \
	docker rm -f -v $(CONTAINER_ID) > /dev/null ; \
	rm -f $(CONTAINER_ID_FILE) ; \
	echo "Stopped Container $(CONTAINER_ID)"

restart:
	$(MAKE) stop
	$(MAKE) start

shell: status
	docker exec -it $(CONTAINER_ID) /bin/bash -

test:
	@if [ -z "$(CONTAINER_ID)" ]; then \
		echo "ERROR: Container Not Running" >&2 ; \
		exit 1 ; \
	fi
	@# need a way to ask the container to wait until all services up
	docker exec $(CONTAINER_ID) wait-for-boot
	docker exec -it $(CONTAINER_ID) ansible-galaxy install -r ${MOUNT_PATH}/requirements.yml
	docker exec -it $(CONTAINER_ID) env ANSIBLE_FORCE_COLOR=yes \
		ansible-playbook -e privileged=$(PRIVILEGED) -e selinux_host=$(SELINUX_HOST) $(MOUNT_PATH)/test.yml

test-clean:
	$(MAKE) restart
	$(MAKE) test
