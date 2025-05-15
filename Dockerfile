ARG BUILD_DIR
ARG BINARY

FROM quay.io/projectquay/golang:1.24 AS builder

WORKDIR /go/src/app
COPY . .
RUN make deps
RUN make build

FROM alpine:latest

ARG BINARY
ARG BUILD_DIR
ENV BINARY=${BINARY}
WORKDIR /
COPY --from=builder /go/src/app/${BUILD_DIR}/${BINARY} .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/bin/sh", "-c", "./$BINARY"]