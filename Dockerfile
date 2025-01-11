FROM golang:alpine AS builder

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GOPATH=/go

WORKDIR /build

# Copy go.mod and go.sum files first to leverage Docker cache
COPY go.mod go.sum ./
RUN go mod download

# Copy the entire project
COPY . .

WORKDIR /build/cmd/api

RUN go build -o main .

FROM scratch

COPY --from=builder /build/cmd/api/main .
COPY --from=builder /build/config /config
COPY --from=builder /build/db /db
COPY --from=builder /build/dto /dto
COPY --from=builder /build/handlers /handlers
COPY --from=builder /build/router /router
COPY --from=builder /build/server /server
COPY --from=builder /build/schema.sql /schema.sql
COPY --from=builder /build/.env .env
COPY --from=builder /build/logs /logs

ENTRYPOINT ["/main"]