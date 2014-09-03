# Slack invitation request page for Hubot

[![Build Status](https://travis-ci.org/hubot-scripts/hubot-slack-invite-request.svg)](https://travis-ci.org/hubot-scripts/hubot-slack-invite-request)
[![Gitter chat](https://badges.gitter.im/hubot-scripts/hubot-slack-invite-request.png)](https://gitter.im/hubot-scripts/hubot-slack-invite-request)

> This script is designed specifically for use with the [Slack adapter](https://github.com/tinyspeck/hubot-slack).

---

> **NB!** This script currently depends on un-merged changes to the Hubot core source. As of right now, you must specify `git://github.com/therealklanni/hubot.git#18146ab4` as the package version for `hubot` in your `package.json`. This notice will be removed when the changes are merged upstream to hubot core.

---

Serves pages from your Hubot which authenticates users via Google Sign-In and 
then displays a form for requesting an invite to a [Slack](http://slack.com) team.
When the form is submitted, the details are posted to your channel/group on Slack.

The user will see each page in the following order:

1. login
2. apply
3. thanks

## Installation

`npm install hubot-slack-invite-request`

Then add `"hubot-slack-invite-request"` to `external-scripts.json`

## Configuration

### Google API key

To use this script, you will need a Google API developer key. Visit the [Google
Developer Console](https://console.developers.google.com) to set up a new project.

1. In the Developer Console, click `Add Project` to create a new project.
2. On the Project Dashboard, click `Enable an API` and turn on `Google+ API`
3. Click on `Credentials` on the left navigation (under "APIs and Auth")
4. Click on `Create new Client ID` under "OAuth"
5. Choose "Web application"
6. In the "Authorized JavaScript Origins" text box, enter your Hubot URL (e.g. http://myhubot.com)
7. In the "Authorized Redirect URL" text box, enter "http://myhubot.com/login"
8. Copy the `ClientID` into strings.yml

### Environment variables

* `EXPRESS_STATIC` - absolute path to the `src/static` directory of this module (e.g. `/opt/hubot/node_modules/hubot-slack-invite-request/src/public`)
* `HUBOT_SLACK_ADMIN_CHANNEL` - the destination for the request notifications from Hubot; this can be a public channel or private group.
* `HUBOT_BASE_URL` - the base URL for where your hubot lives (e.g. http://myhubot.com/), *please include the trailing slash*

These should be configured in your hubot initialization script. Or, for example,
on Heroku you would run:

```sh
heroku config:set ENV_VARIABLE=value
```

### Strings

You can customize each page by modifying the `strings.yml` file.

The `strings.yml` file is set up as follows:

```yml
apply:
  # ... strings for application page ...
  header:
    # ... strings for the page header ...
  form:
    # ... form field configuration ...
thanks:
  # ... strings for thank you page ...
login:
  # ... strings for login page ...
```

In the `form` section of `apply`, the `fullName` and `email` blocks should be
considered necessary for proper functionality of the script. However, you can
still customize these fields by editing these (and only these) properties: 

* `class`
* `title`
* `required`
* `readonly`
* `help` (not provided by default).

In the `custom` section of `form`, you can modify *any* of the values as you see
fit, or add/remove blocks, or even remove the `custom` section entirely, if
you like.

The default configuration should sufficiently provide varying examples of custom
field configurations. More advanced users can also modify the view templates 
themselves for even higher degree of customization. If you choose to do this,
please note that the `fullName` and `email` should still be considered necessary.

## Commands

*None*
