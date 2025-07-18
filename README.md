# SDK Clients 

This repository contains three minimal SDK clients:

- **Go** client in `go-client/`
- **TypeScript** client in `ts-client/`
- **Python** client in `py-client/`

## Environment

This project uses a `.env` file at the repo root to configure secrets and endpoints.  
The real `.env` is ignored by Git; to get started:

1. Copy the example file:
   ```bash
   cp .env.example .env

2. Open .env in your editor and fill in your own values:

## Build, Run & Update

All commands assume you’re in the repo root and have your `.env` set up.

```bash
# Build Go, TS & Python clients
make build

# Run all clients
make run

# Pull in the latest Cribl SDKs across all clients
make update-sdk