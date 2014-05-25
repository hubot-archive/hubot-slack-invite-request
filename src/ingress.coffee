# Description
#   Ingress helper commands for Hubot
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot AP until|to <N> - tells you the AP required for N level
#   hubot AP all - prints the AP requirements for each level
#
# Author:
#   therealklanni

# Quick refrence for what badges are need at what level
# LVL   Badges              AP          Max xm
# 9   4 Silver, 1 Gold,     2400000,    10900
# 10  5 Silver, 2 Gold,     4000000,    11700
# 11  6 Silver, 4 Gold,     6000000,    12400
# 12  7 Silver, 6 Gold,     8400000,    13000
# 13  7 Gold, 1 Plat,       12000000,   13500
# 14  2 Plat,               17000000,   13900
# 15  3 Plat,               24000000,   14200
# 16  4 Plat, 2 Black,      40000000,   14400

levels =
  1:
    ap: 0
    xm: 3000
  2:
    ap: 10000
    xm: 4000
  3:
    ap: 30000
    xm: 5000
  4:
    ap: 70000
    xm: 6000
  5:
    ap: 150000
    xm: 7000
  6:
    ap: 300000
    xm: 8000
  7:
    ap: 600000
    xm: 9000
  8:
    ap: 1200000
    xm: 10000
  9:
    ap: 2400000
    xm: 10900
    badges:
      silver: 4
      gold: 1
  10:
    ap: 4000000
    xm: 11700
    badges:
      silver: 5
      gold: 2
  11:
    ap: 6000000
    xm: 12400
    badges:
      silver: 6
      gold: 4
  12:
    ap: 8400000
    xm: 13000
    badges:
      silver: 7
      gold: 6
  13:
    ap: 12000000
    xm: 13500
    badges:
      gold: 7
      platinum: 1
  14:
    ap: 17000000
    xm: 13900
    badges:
      platinum: 2
  15:
    ap: 24000000
    xm: 14200
    badges:
      platinum: 3
  16:
    ap: 40000000
    xm: 14400
    badges:
      platinum: 4
      black: 2

badgeList = [
  'builder1', 'builder2', 'builder3', 'builder4', 'builder5',
  'connector1', 'connector2', 'connector3', 'connector4', 'connector5',
  'explorer1', 'explorer2', 'explorer3', 'explorer4', 'explorer5',
  'founder',
  'guardian1', 'guardian2', 'guardian3', 'guardian4', 'guardian5',
  'hacker1', 'hacker2', 'hacker3', 'hacker4', 'hacker5',
  'initio',
  'interitus',
  'liberator1', 'liberator2', 'liberator3', 'liberator4', 'liberator5',
  'mindcontroller1', 'mindcontroller2', 'mindcontroller3', 'mindcontroller4', 'mindcontroller5',
  'pioneer1', 'pioneer2', 'pioneer3', 'pioneer4', 'pioneer5',
  'purifier1', 'purifier2', 'purifier3', 'purifier4', 'purifier5',
  'recharger1', 'recharger2', 'recharger3', 'recharger4', 'recharger5',
  'recursion',
  'seer1', 'seer2', 'seer3', 'seer4', 'seer5',
  'verified'
]

module.exports = (robot) ->
  badges =
    add: (user, badgeName) ->
      userBadges = robot.brain.data.ingressBadges[user.id] ?= []
      userBadges.push ":#{badgeName}:"
    del: (user, badgeName) ->
      robot.brain.data.ingressBadges[user.id] = (badges.forUser user).filter (x) ->
        x isnt ":#{badgeName}:"
    forUser: (user) ->
      robot.brain.data.ingressBadges[user.id] ?= []

  sayBadges = (a) ->
    badgeReq = for kind, amt of a
      Array(amt+1).join ":#{kind}:"

  robot.brain.on 'loaded', ->
    robot.brain.data.ingressBadges ?= {}

  robot.respond /AP\s+(?:to|(?:un)?til)\s+L?(\d{1,2})/i, (msg) ->
    [lv, lvl] = [msg.match[1], levels[msg.match[1]]]
    if lvl.badges?
      badgeReq = sayBadges lvl.badges
    msg.reply "You need #{lvl.ap} AP#{if badgeReq? then ' ' + badgeReq.join ' ' else ''}
 to reach L#{lv}#{if lv > 15 then ' (hang in there!)' else ''}"

  robot.respond /AP all/i, (msg) ->
    lvls = for lv, lvl of levels
      if lvl.badges?
        badgeReq = sayBadges lvl.badges
      "\nL#{lv} = #{lvl.ap} AP#{if badgeReq? then ' ' + badgeReq.join ' ' else ''}"
    msg.send lvls.join ""

  robot.respond /(I|@?\w+) (?:have|has|got|earned)(?: the)? :?(\w+):? badge/i, (msg) ->
    who = msg.match[1].replace '@', ''
    badgeName = msg.match[2]

    if who.toLowerCase() == 'i'
      who = msg.envelope.user
    else
      who = robot.brain.userForName who

    if badgeName in badgeList
      badges.add who, badgeName
      if who.name == msg.envelope.user.name
        msg.reply "congrats on earning the :#{badgeName}: badge!"
      else
        msg.send "@#{who.name}: congrats on earning the :#{badgeName}: badge!"
    else
      msg.reply "Invalid badge name. Available badges are: #{badgeList.join ', '}"

  robot.respond /wh(?:at|ich) badges? do(?:es)? (I|@?\w+) have/i, (msg) ->
    who = msg.match[1].replace '@', ''

    if who.toLowerCase() == 'i'
      who = msg.envelope.user
    else
      who = robot.brain.userForName who

    userBadges = badges.forUser who
    you = if who? and who.name == msg.envelope.user.name then true else false
    whowhat = "#{if you then 'You have' else who.name + ' has'}"

    if who? and userBadges.length > 0
      msg.reply "#{whowhat} the following badges: #{userBadges.join ' '}"
    else
      msg.reply "#{whowhat} no badges."

  robot.respond /(I|@?\w+) (?:do(?:n't|esn't| not)) have the :?(\w+):? badge/i, (msg) ->
    who = msg.match[1].replace '@', ''
    badgeName = msg.match[2]

    if who.toLowerCase() == 'i'
      who = msg.envelope.user
    else
      who = robot.brain.userForName who

    if ":#{badgeName}:" in badges.forUser who
      badges.del who, badgeName
      msg.reply "removed the :#{badgeName}: badge"
