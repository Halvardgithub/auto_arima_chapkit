# auto_arima_chapkit

An ARIMA model which automatically chooses hyperparameters using the `ARIMA()` function from the fable R package, wrapped as a chapkit ML service.

This project was scaffolded using the [Chapkit](https://dhis2-chap.github.io/chapkit) CLI.

## Quick Start

### Run from GHCR (no build needed)

```bash
docker compose -f compose.ghcr.yml up
```

### Build and run locally

```bash
docker compose up --build
```

Or using Make:

```bash
make run
```

The API will be available at:
- API: http://localhost:8000
- API Docs: http://localhost:8000/docs

### Development Mode

Install dependencies and run the service locally:

```bash
uv sync
uv run python main.py
```

## Project Structure

```
auto_arima_chapkit/
├── main.py                    # FastAPI app and model configuration
├── scripts/                   # R scripts for training and prediction
│   ├── train.R                # Training script (fable ARIMA)
│   ├── predict.R              # Prediction script
│   └── utils.R                # Shared utility functions
├── example_data/              # Example weekly data (CSV)
├── example_data_monthly/      # Example monthly data (CSV)
├── pyproject.toml             # Python dependencies
├── Dockerfile                 # Docker build configuration
├── compose.yml                # Docker Compose (local build)
├── compose.ghcr.yml           # Docker Compose (GHCR image)
├── Makefile                   # Shortcuts: build, run, run-ghcr
└── .github/workflows/
    ├── ci.yml                 # CI: Docker build + chapkit test
    └── publish-docker.yml     # Publish image to GHCR on push/tag
```

## API Endpoints

### Health Check

```bash
curl http://localhost:8000/health
```

### Configuration Management

Create a configuration:

```bash
curl -X POST http://localhost:8000/api/v1/configs \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my-config",
    "data": {}
  }'
```

### ML Operations

Train a model:

```bash
curl -X POST http://localhost:8000/api/v1/ml/\$train \
  -H "Content-Type: application/json" \
  -d '{
    "config_id": "YOUR_CONFIG_ID",
    "data": { ... }
  }'
```

Make predictions:

```bash
curl -X POST http://localhost:8000/api/v1/ml/\$predict \
  -H "Content-Type: application/json" \
  -d '{
    "model_id": "YOUR_MODEL_ID",
    "future": { ... }
  }'
```

## Makefile targets

| Target       | Description                              |
|--------------|------------------------------------------|
| `make build` | Build the Docker image locally           |
| `make run`   | Build and run the image on port 8000     |
| `make run-ghcr` | Pull and run the prebuilt GHCR image  |

## Documentation

- [Chapkit Documentation](https://dhis2-chap.github.io/chapkit)
- [FastAPI Documentation](https://fastapi.tiangolo.com)
