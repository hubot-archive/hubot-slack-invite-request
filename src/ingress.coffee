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

apToLv = [0, 0, 10000, 30000, 70000, 150000, 300000, 600000, 1200000, 2400000, 4000000, 6000000, 8400000, 12000000, 17000000, 24000000, 40000000]

module.exports = (robot) ->

  robot.respond /AP\s+(?:to|(?:un)?til)\s+L?(\d{1,2})/i, (msg) ->
    lv = msg.match[1]
    ap = apToLv[lv]
    msg.reply "You need #{ap} AP to reach L#{lv}" if ap

  robot.respond /AP all/i, (msg) ->
    msg.send "L#{i+1} = #{ap} AP" for ap, i in apToLv.slice 1
