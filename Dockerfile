FROM golang:1.22.5-alpine AS build_deps

RUN apk add --no-cache git

WORKDIR /workspace

COPY go.mod .
COPY go.sum .

RUN go mod download

FROM build_deps AS build

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o webhook -ldflags '-w -extldflags "-static"' .

FROM alpine:3.20

RUN apk add --no-cache ca-certificates

COPY --from=build /workspace/webhook /usr/local/bin/webhook

ENTRYPOINT ["webhook"]
