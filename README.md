# Ingress Hubot

A collection of Ingress-related commands for Hubot. This script is designed
specifically for use with the Slack adapter.

[![Build Status](https://travis-ci.org/therealklanni/hubot-ingress.svg)](https://travis-ci.org/therealklanni/hubot-ingress)

## Features

* Report level requirements
* List requirements for all levels
* Store badge information for players
* *much more to come...*

## Installation

`npm install hubot-ingress`

Go to the custom emojis page of your Slack team. Upload each of the images from
the `badges/` subfolder, naming them the same as their filename (without the extension).
These emoji will be used by Hubot.

## Configuration

*None*

## Commands

### AP requirement

Reports the AP/badge requirements for the specified level.

`hubot AP until L<level>`

### List levels

Show the AP/badge requirements for every level.

`hubot AP all`

### Add badges

Badges can be added one by one or multiples at a time, and can be added for other players.
Badges that have levels end with a number representing that level (1=bronze, 2=silver, etc).
When a badge is added that is the same as an existing badge (hacker5 vs hacker1, for example),
then the new badge will replace the existing badge.

`hubot I have the hacker3, founder badges`

`hubot user1 has the recursion badge`

### Remove badges

Badges can be removed one by one.

`hubot I don't have the hacker1 badge`
