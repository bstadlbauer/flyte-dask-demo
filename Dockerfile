FROM python:3.8-buster

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install awscli

COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt


# Hack to get local AWS access to work
RUN echo '#!/bin/bash\n/usr/local/bin/aws --endpoint-url http://minio.flyte.svc.cluster.local:9000 "$@"' > /usr/bin/aws && \
    chmod +x /usr/bin/aws
ENV PATH="/usr/bin:$PATH"
ENV AWS_ACCESS_KEY_ID=minio
ENV AWS_SECRET_ACCESS_KEY=miniostorage

# Fastregistration unzips here
ENV PYTHONPATH="/root":$PYTHONPATH