SHELL := /usr/bin/env bash
PYTHON := python3
ifeq ($(shell uname),Darwin)
SED_INPLACE := -i ''
else
SED_INPLACE := -i
endif

.PHONY: all build run go-build go-run ts-build ts-run py-build py-run clean  update-sdk update-go-sdk update-ts-sdk update-py-sdk help

# Default: build everything
all: build           ## Build all clients

# Build all clients
build: go-build ts-build py-build  ## Build Go, TS, and Python clients

# Run all clients
run: go-run ts-run py-run          ## Run Go, TS, and Python clients

# --- Go client ---
go-build:                         ## Tidy Go modules
	cd go-client && \
	go mod tidy

go-run:                           ## Run the Go client
	cd go-client && \
	go run main.go

# --- TypeScript client ---
ts-build:                         ## Install & build the TS client
	cd ts-client && \
	npm install && \
	npm run build

ts-run:                           ## Start the TS client
	cd ts-client && \
	npm start

# --- Python client ---
py-build:                         ## Create venv & install Python deps
	cd py-client && \
	$(PYTHON) -m venv venv && \
	venv/bin/pip install --upgrade pip && \
	venv/bin/pip install -r requirements.txt

py-run:                           ## Run the Python client
	cd py-client && \
	venv/bin/python client.py

# --- Clean artifacts ---
clean:                            ## Remove build artifacts
	rm -rf go-client/go.sum \
	       ts-client/node_modules ts-client/dist \
	       py-client/venv py-client/__pycache__

update-sdk: update-go-sdk update-ts-sdk update-py-sdk. ## Update Go, TS, and Python SDKs to the latest cribl-control-plane versions
	@echo "All SDKs updated to latest cribl-control-plane versions"

update-go-sdk:   ## Update Go client to latest cribl-control-plane-sdk-go
	cd go-client && \
	go get github.com/criblio/cribl-control-plane-sdk-go@latest && \
	go mod tidy

update-ts-sdk:   ## Update TS client to latest cribl-control-plane
	cd ts-client && \
	npm install cribl-control-plane@latest --save

update-py-sdk:   ## Update Python client to latest cribl-control-plane
	cd py-client && \
	LATEST_TAG=$$( \
	  git ls-remote --tags https://github.com/criblio/cribl_control_plane_sdk_python.git \
	    | awk -F/ '{print $$NF}' \
	    | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$$' \
	    | sort -V \
	    | tail -n1 \
	) && \
	sed -i.bak -E "s#(cribl_control_plane_sdk_python\.git@)[^#]+#\1$${LATEST_TAG}#" requirements.txt && \
	rm requirements.txt.bak &&  \
	venv/bin/pip install --upgrade -r requirements.txt

# --- Help ---
help:                             ## Show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?##' $(MAKEFILE_LIST) | \
	while IFS= read -r line; do \
	  target=$${line%%:*}; \
	  desc=$${line##*## }; \
	  echo -e "  \e[36m$${target}\e[0m $${desc}"; \
	done
