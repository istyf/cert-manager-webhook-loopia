FROM golang:1.16.4 AS build_deps

WORKDIR /workspace

COPY go.mod .
COPY go.sum .

RUN go mod download

FROM build_deps AS build

COPY . .

RUN CGO_ENABLED=0 go build -o webhook -ldflags '-w -extldflags "-static"' .

FROM registry.access.redhat.com/ubi8/ubi-minimal

WORKDIR /opt/webhook

COPY --from=build --chown=1001 /workspace/webhook /opt/webhook/webhook

RUN chown 1001 /opt/webhook
RUN chmod 700 /opt/webhook

USER 1001

ENTRYPOINT ["/opt/webhook/webhook", "--secure-port", "8443"]
