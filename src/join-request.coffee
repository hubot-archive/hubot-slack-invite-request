fs = require 'fs'
cons = require 'consolidate'

module.exports = (robot) ->
  app = robot.router
  team = process.env.HUBOT_SLACK_TEAM or ''

  app.engine 'html', cons.hogan
  app.set 'view engine', 'html'
  app.set 'views', "#{__dirname}/views"

  app.get '/apply', (req, res) ->
    viewData =
      team: team
    res.render 'index', viewData

  app.post '/apply', (req, res) ->
    viewData =
      team: team
      fullName: req.body.fullName
      email: req.body.email

    res.render 'thanks', viewData

    # clean up temporary file
    fs.unlink req.files.screenshot.path
