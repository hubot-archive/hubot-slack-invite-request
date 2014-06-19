fs = require 'fs'
cons = require 'consolidate'

validate = (req, res, next) ->
  if req.session.user?
    next()
  else
    req.session.error = 'Not Authenticated'
    res.redirect '/login'

module.exports = (robot) ->
  app = robot.router
  env = process.env
  team = env.HUBOT_SLACK_TEAM or ''

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
    viewData =
      team: team
      title: env.HUBOT_INGRESS_INVITE_TITLE or "You're almost there!"
      description: env.HUBOT_INGRESS_INVITE_DESC or 'Please fill out
 the form below and upload your verification screenshot to complete your
 application. We have attempted to determine your agent name automatically,
 please check that this information is correct. Your application will be
 reviewed as quickly as possible and your invitation will be sent to the email
 address below if you are approved.'
      fullName: user.displayName
      givenName: user.name.givenName
      nickname: user.nickname
      email: user.emails[0].value

    res.render 'apply', viewData

  app.post '/apply', validate, (req, res) ->
    user = req.session.user
    fileTemp = req.files.screenshot.path
    filename = "images/#{fileTemp.split('/').pop()}." + req.files.screenshot.name.split('.').pop()
    imageUrl = env.HUBOT_BASE_URL.replace /\/$/, "/#{filename}"

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
          text: if req.files.screenshot.name then "#{imageUrl}" else '<no screenshot>'
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
