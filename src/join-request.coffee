fs = require 'fs'
cons = require 'consolidate'
yaml = require 'js-yaml'
path = require 'path'
strings = yaml.safeLoad fs.readFileSync path.resolve "#{__dirname}/../strings.yml"
loginTpl = strings.login
applyTpl = strings.apply
thanksTpl = strings.thanks

validate = (req, res, next) ->
  if req.session.user?
    next()
  else
    req.session.error = 'Not Authenticated'
    res.redirect '/login'

rateLimit = (req, res, next) ->
  if not req.session.time? or Date.now() - req.session.time > 3600000
    next()
  else
    res.send 429, "Woah, #{req.session.user.name.givenName}, got a little over-excited there, did ya?"

module.exports = (robot) ->
  app = robot.router
  env = process.env
  team = env.HUBOT_SLACK_TEAM or ''
  url = env.HUBOT_BASE_URL or 'http://please-set-HUBOT_BASE_URL/'

  robot.brain.on 'loaded', ->
    robot.brain.data.ingressAgents ?= []

  app.engine 'html', cons.hogan
  app.set 'view engine', 'html'
  app.set 'views', "#{__dirname}/views"

  app.post '/login', (req, res) ->
    if req.body.user?.kind is 'plus#person'
      req.session.user = req.body.user
      res.send 200
    else
      res.send 401

  app.get '/login', (req, res) ->
    if req.session.user?
      res.redirect '/apply'
    else
      res.render 'login'

  app.get '/apply', validate, (req, res) ->
    user = req.session.user

    applyTpl.form.fullName.value = user.displayName
    applyTpl.form.email.value = user.emails[0].value

    viewData =
      partials:
        field: 'field'
      team: team
      user: user
      apply: applyTpl

    res.render 'apply', viewData

  app.post '/apply', rateLimit, validate, (req, res) ->
    req.session.time = Date.now()
    user = req.session.user
    fileTemp = req.files.screenshot.path
    filename = "images/#{fileTemp.split('/').pop()}." + req.files.screenshot.name.split('.').pop()
    imageUrl = url.replace /\/$/, "/#{filename}"

    fs.rename fileTemp, "#{__dirname}/public/#{filename}", (err) ->
      if err?
        res.send 500
      viewData =
        team: team
        fullName: user.displayName
        email: user.emails[0].value
        imagePath: filename

      res.render 'thanks', viewData

      user.agentName = req.body.agentName.slice 0, 32
      user.community = req.body.community.slice 0, 140
      user.comments = req.body.comments.slice 0, 140

      robot.brain.data.ingressAgents = robot.brain.data.ingressAgents.filter (agent) ->
        agent.emails[0].value != user.emails[0].value
      robot.brain.data.ingressAgents.push user
      robot.brain.save()

      payload =
        message:
          reply_to: env.HUBOT_SLACK_ADMIN_CHANNEL or 'invites'
        content:
          fallback: "New invite request from #{user.displayName}"
          pretext: "#{user.displayName} would like to join Slack!"
          text: (if req.files.screenshot.name then "#{imageUrl}" else '<no screenshot>') + " | #{user.url}"
          fields: [
            {title: 'Full Name'
            value: user.displayName
            short: true},
            {title: 'Email'
            value: user.emails[0].value
            short: true},
            {title: 'Agent Name'
            value: user.agentName
            short: true},
            {title: 'Community'
            value: user.community or '<none>'
            short: true},
            {title: 'Comments'
            value: user.comments or '<none>'
            short: false}
          ]

      robot.emit 'slack-attachment', payload
