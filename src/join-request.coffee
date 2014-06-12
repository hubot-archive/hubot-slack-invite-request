cons = require 'consolidate'

module.exports = (robot) ->
  app = robot.router

  app.engine 'html', cons.hogan
  app.set 'view engine', 'html'
  app.set 'views', "#{__dirname}/views"

  app.get '/apply', (req, res) ->
    viewData =
      team: process.env.HUBOT_SLACK_TEAM or ''
    res.render 'index', viewData
