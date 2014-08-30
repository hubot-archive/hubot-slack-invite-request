# Slack join request page for Hubot

Serves a page from your Hubot which authenticates users via Google Sign In and 
then displays a form for requesting an invite to a [Slack](http://slack.com) team.
When the form is submitted, the details are posted to your channel/group on Slack.

> This script is designed specifically for use with the Slack adapter.

[![Build Status](https://travis-ci.org/hubot-scripts/hubot-slack-invite-request.svg)](https://travis-ci.org/hubot-scripts/hubot-slack-invite-request)
[![Gitter chat](https://badges.gitter.im/hubot-scripts/hubot-slack-invite-request.png)](https://gitter.im/hubot-scripts/hubot-slack-invite-request)

## Installation

`npm install hubot-slack-invite-request`

Then add `"hubot-slack-invite-request"` to `external-scripts.json`

## Configuration

Start by modifying the `strings.yml` file to set up the application form, "thank you" page, and "login" page.

The `strings.yml` file is set up as follows:

```yml
apply:
  # ... strings for application page ...
thanks:
  # ... strings for thank you page ...
login:
  # ... strings for login page ...
```

The user will see each page in the following order:

1. login (unless user is already logged in)
2. apply
3. thanks


## Commands

*None*
