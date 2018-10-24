.PHONY: build
build:
	cp -r ${GOPATH}/src/github.com/tantona/codebuild-slack-notification/* ./addons/send-slack-notification
	docker build -t 463866799928.dkr.ecr.us-east-1.amazonaws.com/codebuild-image .
