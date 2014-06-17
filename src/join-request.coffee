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
  team = process.env.HUBOT_SLACK_TEAM or ''

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
      title: process.env.HUBOT_INGRESS_INVITE_TITLE or "You're almost there!"
      description: process.env.HUBOT_INGRESS_INVITE_DESC or 'Please fill out
 the form below and upload your verification screenshot to complete your
 application. We have attempted to determine your agent name automatically,
 please check that this information is correct. Your application will be
 reviewed as quickly as possible and your invitation will be sent to the email
 address below if you are approved.'
      fullName: user.displayName
      givenName: user.name.givenName
      nickname: user.nickname
      email: user.emails[0].value

    res.render 'index', viewData

  app.post '/apply', validate, (req, res) ->
    viewData =
      team: team
      fullName: req.body.fullName
      email: req.body.email

    res.render 'thanks', viewData

    # clean up temporary file
    fs.unlink req.files.screenshot.path
