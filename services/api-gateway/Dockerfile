# syntax=docker/dockerfile:1

FROM golang:1.22

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download 

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /api-gateway

EXPOSE 8080

# Run the binary when the container starts
CMD ["/api-gateway"]