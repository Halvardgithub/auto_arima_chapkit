ARG BASE_PLATFORM=linux/amd64

FROM --platform=${BASE_PLATFORM} ghcr.io/dhis2-chap/docker_for_madagascararima:master

COPY --from=ghcr.io/astral-sh/uv:0.11 /uv /uvx /usr/local/bin/

RUN apt-get update && apt-get install -y python3.13

ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PROJECT_ENVIRONMENT=/app/.venv \
    UV_PYTHON=python3.13 \
    UV_PYTHON_PREFERENCE=only-system \
    PATH="/app/.venv/bin:${PATH}"

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

COPY main.py ./
COPY scripts/ ./scripts/

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]