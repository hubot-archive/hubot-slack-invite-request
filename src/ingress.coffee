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

apToLv = [0, 0, 10000, 30000, 70000, 150000, 300000, 600000, 1200000, 2400000,
          4000000, 6000000, 8400000, 12000000, 17000000, 24000000, 40000000]
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
  badges = {}

  robot.brain.on "loaded", ->
    badges = robot.brain.data.ingressBadges ?= {}

  robot.respond /AP\s+(?:to|(?:un)?til)\s+L?(\d{1,2})/i, (msg) ->
    lv = msg.match[1]
    ap = apToLv[lv]
    msg.reply "You need #{ap} AP to reach L#{lv}" if ap

  robot.respond /AP all/i, (msg) ->
    msg.send "L#{i+1} = #{ap} AP" for ap, i in apToLv.slice 1

  robot.respond /(I|@?\w+) (?:have|has|got|earned)(?: the)? :?(\w+):? badge/i, (msg) ->
    who = msg.match[1].replace '@', ''
    badgeName = msg.match[2]

    if who.toLowerCase() == 'i'
      who = msg.envelope.user
    else
      who = robot.brain.userForName who

    userBadges = badges[who.id] ?= []

    if badgeName in badgeList
      userBadges.push ":#{badgeName}:"
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

    userBadges = badges[who.id] = []
    you = if who? and who.name == msg.envelope.user.name then true else false
    whowhat = "#{if you then 'You have' else who.name + ' has'}"

    if who? and userBadges.length > 0
      msg.reply "#{whowhat} the following badges: #{userBadges.join ' '}"
    else
      msg.reply "#{whowhat} no badges."
