package main

import (
	"fmt"
	"os"
	"strings"

	"github.com/ashwanthkumar/slack-go-webhook"
	"github.com/sirupsen/logrus"
	"gopkg.in/alecthomas/kingpin.v2"
)

const (
	StatusBuildStarted   = "BUILD_STARTED"
	StatusBuildSucceeded = "BUILD_SUCCEEDED"
	StatusBuildFailed    = "BUILD_FAILED"
)

func stringp(s string) *string {
	return &s
}

var (
	status     = kingpin.Flag("status", "Codebuild status").Short('s').String()
	project    = kingpin.Flag("project", "Codebuild project name").Short('p').String()
	webhookURL = kingpin.Flag("webhook-url", "Slack Webhook url").Short('u').String()
)

func main() {
	kingpin.Parse()

	payload := slack.Payload{
		Attachments: []slack.Attachment{},
	}

	codebuildBuildID := os.Getenv("CODEBUILD_BUILD_ID")
	region := os.Getenv("AWS_REGION")
	buildURL := fmt.Sprintf("https://console.aws.amazon.com/codesuite/codebuild/projects/%s/build/%s/log?region=%s", strings.Split(codebuildBuildID, ":")[1], codebuildBuildID, region)

	switch *status {
	case StatusBuildStarted:
		payload.Attachments = append(payload.Attachments, slack.Attachment{
			Color:     stringp("#ff784e"),
			Title:     stringp(fmt.Sprintf("Codebuild Project: %s", *project)),
			TitleLink: &buildURL,
			Text:      stringp("Build started..."),
		})
		break
	case StatusBuildSucceeded:
		payload.Attachments = append(payload.Attachments, slack.Attachment{
			Color:     stringp("#4caf50"),
			Title:     stringp(fmt.Sprintf("Codebuild Project: %s", *project)),
			TitleLink: &buildURL,
			Text:      stringp("Build succeeded"),
		})
		break
	case StatusBuildFailed:
		payload.Attachments = append(payload.Attachments, slack.Attachment{
			Color:     stringp("#f44336"),
			Title:     stringp(fmt.Sprintf("Codebuild Project: %s", *project)),
			TitleLink: &buildURL,
			Text:      stringp("Build Failed"),
		})
		break
	default:
		payload.Attachments = append(payload.Attachments, slack.Attachment{
			Color:     stringp("#ffffff"),
			Title:     stringp(fmt.Sprintf("Codebuild Project: %s", *project)),
			TitleLink: &buildURL,
			Text:      stringp(fmt.Sprintf("Status not recognized: %v", *status)),
		})
		break
	}

	errs := slack.Send(*webhookURL, "", payload)
	if len(errs) > 0 {
		for _, err := range errs {
			logrus.WithError(err).Errorf("unable to send webhook to %s", *webhookURL)
		}
	}
}
