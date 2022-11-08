# Build - Start a golang base image
ARG GO_VERSION
FROM golang:${GO_VERSION}-alpine

LABEL maintainer "Tarpan Pathak <tarpanpathak720@gmail.com>"

WORKDIR /src

COPY go.mod ./
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /src/simplehttpserver

# Deploy - Start with a scratch image (no layers)
FROM scratch

WORKDIR /

COPY --from=0 /src/simplehttpserver /simplehttpserver

EXPOSE 8080

ENTRYPOINT ["/simplehttpserver"]