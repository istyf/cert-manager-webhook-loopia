FROM golang:1.16.4 AS build_deps

WORKDIR /workspace

COPY go.mod .
COPY go.sum .

RUN go mod download

FROM build_deps AS build

COPY . .

RUN CGO_ENABLED=0 go build -o webhook -ldflags '-w -extldflags "-static"' .

FROM registry.access.redhat.com/ubi8/ubi-minimal

COPY --from=build /workspace/webhook /opt/webhook

USER 1001

ENTRYPOINT ["/opt/webhook"]
