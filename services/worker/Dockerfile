# syntax=docker/dockerfile:1

FROM golang:1.22

WORKDIR /app

COPY go.mod ./

RUN go mod download 

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /worker

# Run the binary when the container starts
CMD ["/worker"]
