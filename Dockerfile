# builder image
FROM golang:1.11-alpine3.8 as builder

RUN apk --no-cache add git
RUN go get github.com/golang/dep/cmd/dep
WORKDIR /go/src/github.com/linki/chaoskube
COPY . .
RUN dep ensure -vendor-only
RUN go test -v ./...
ENV GOARCH amd64
RUN go build -o /bin/chaoskube -v \
  -ldflags "-X main.version=$(git describe --tags --always --dirty) -w -s"

# final image
FROM alpine:3.8
MAINTAINER Linki <linki+docker.com@posteo.de>

RUN apk --no-cache add ca-certificates dumb-init tzdata
COPY --from=builder /bin/chaoskube /bin/chaoskube

USER 65534
ENTRYPOINT ["dumb-init", "--", "/bin/chaoskube"]
