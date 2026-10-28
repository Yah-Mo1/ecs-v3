# syntax=docker/dockerfile:1

# Build the worker service - stage 1
FROM golang:1.22-alpine AS builder

WORKDIR /app

COPY go.mod ./

RUN go mod download && go mod verify

COPY *.go ./

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -o /worker


# Build the worker service - stage 2
FROM gcr.io/distroless/static-debian12 AS runner

WORKDIR /app

COPY --from=builder /worker /app/worker

USER nonroot:nonroot

# Run the binary when the container starts
CMD ["/app/worker"]