# syntax=docker/dockerfile:1

# Build the dashboard-api service - stage 1
FROM golang:1.22-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download && go mod verify

COPY *.go ./
COPY static ./static

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -o /dashboard-api


# Build the dashboard-api service - stage 2
FROM gcr.io/distroless/static-debian12 AS runner

WORKDIR /app

COPY --from=builder /dashboard-api /app/dashboard-api

USER nonroot:nonroot

# Run the binary when the container starts
CMD ["/app/dashboard-api"]