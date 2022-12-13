FROM ubuntu:22.04 as builder

WORKDIR /app

ARG VERSION=v4.9.6
ARG BINARY=yq_linux_386
ARG TASK_VERSION=v3.17.0
ARG TASK_BINARY=task_linux_amd64.tar.gz

RUN apt-get update && apt-get install -y \
    npm \
    wget \
    wkhtmltopdf \
    libfontconfig1 \
    libxtst6 \
    rubygems \
    && rm -rf /var/lib/apt/lists/*

ARG VERSION=v4.9.6
ARG BINARY=yq_linux_386
RUN wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O /usr/bin/yq \ 
    && chmod +x /usr/bin/yq

RUN wget -O- https://github.com/go-task/task/releases/download/${TASK_VERSION}/${TASK_BINARY} \
    | tar xz -C /usr/bin


COPY src/ src/
COPY scripts/ scripts/
COPY Taskfile.yaml Taskfile.yaml
COPY .env .env

ENTRYPOINT ["/usr/bin/task"]

FROM builder as build
RUN task build

FROM busybox as release
WORKDIR /app
COPY --from=build /app/build/cv.html cv.html
VOLUME /app