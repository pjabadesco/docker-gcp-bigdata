## OLD

docker-compose build

## NEW

docker buildx build --platform=linux/amd64 --tag=docker-gcp-bigdata:latest --load .

docker tag docker-gcp-bigdata:latest pjabadesco/docker-gcp-bigdata:0.02
docker push pjabadesco/docker-gcp-bigdata:0.02

docker tag pjabadesco/docker-gcp-bigdata:0.02 pjabadesco/docker-gcp-bigdata:latest
docker push pjabadesco/docker-gcp-bigdata:latest

docker tag pjabadesco/docker-gcp-bigdata:latest ghcr.io/pjabadesco/docker-gcp-bigdata:latest
docker push ghcr.io/pjabadesco/docker-gcp-bigdata:latest
