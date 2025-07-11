SHELL := /usr/bin/env bash
PYTHON := python3

.PHONY: all build run go-build go-run ts-build ts-run py-build py-run clean help

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

# --- Help ---
help:                             ## Show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?##' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":[[:space:]]*"}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
