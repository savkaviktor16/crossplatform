FROM golang:1.24-alpine AS builder

ARG TARGETOS
ARG TARGETARCH
ARG BINARY=app

WORKDIR /go/src/app
COPY . .

RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /go/src/app/${BINARY} .

FROM scratch

ARG BINARY=app
WORKDIR /
COPY --from=builder /go/src/app/${BINARY} /${BINARY}
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/app"]