docker build -f Dockerfile.builder . -t cel-ex-builder
docker rm celex -f
docker run --name celex -d cel-ex-builder
rm celery-exporter
docker cp celex:/app/dist/celery-exporter .