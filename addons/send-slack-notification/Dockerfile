FROM golang:alpine
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
COPY . /go/src/github.com/tantona/codebuild-slack-notification
WORKDIR /go/src/github.com/tantona/codebuild-slack-notification

RUN go install

ENTRYPOINT ["codebuild-slack-notification"]
