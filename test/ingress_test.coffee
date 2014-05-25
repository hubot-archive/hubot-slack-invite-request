chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'ingress', ->
  user =
    name: 'sinon'
    id: 'U123'
  robot =
    respond: sinon.spy()
    hear: sinon.spy()
    brain:
      on: (_, cb) ->
        cb()
      data: {}
      userForName: (who) ->
        forName =
          name: who
          id: 'U234'

  beforeEach ->
    @user = user
    @robot = robot
    @data = @robot.brain.data
    @msg =
      send: sinon.spy()
      reply: sinon.spy()
      envelope:
        user:
          @user
      message:
        user:
          @user

  require('../src/ingress')(robot)

  describe 'respond listener', ->

    it 'registers AP per level listener', ->
      expect(@robot.respond).to.have.been.calledWith(/AP\s+(?:to|(?:un)?til)\s+L?(\d{1,2})/i)

    it 'registers AP for all levels listener', ->
      expect(@robot.respond).to.have.been.calledWith(/AP all/i)

    describe 'badges commands', ->
      it 'registers "have badge" listener', ->
        expect(@robot.respond).to.have.been.calledWith(/(I|@?\w+) (?:have|has|got|earned)(?: the)? :?(\w+):? badge/i)

      it 'registers "what badges" listener', ->
        expect(@robot.respond).to.have.been.calledWith(/wh(?:at|ich) badges? do(?:es)? (I|@?\w+) have/i)

      it 'registers "do not have" listener', ->
        expect(@robot.respond).to.have.been.calledWith(/(I|@?\w+) (?:do(?:n't|esn't| not)) have the :?(\w+):? badge/i)

      it 'responds to "I have the founder badge"', ->
        @msg.match = [0, 'I', 'founder']
        @robot.respond.args[2][1](@msg)
        badges = @data.ingressBadges.U123
        expect(@msg.reply).to.have.been.calledWith('congrats on earning the :founder: badge!')
        expect(badges).to.be.a('array')
        expect(badges).to.include(':founder:')

      it 'responds to "sinon2 has the verified badge"', ->
        @msg.match = [0, 'sinon2', 'verified']
        @robot.respond.args[2][1](@msg)
        badges = @data.ingressBadges.U234
        expect(@msg.send).to.have.been.calledWith('@sinon2: congrats on earning the :verified: badge!')
        expect(badges).to.be.a('array')
        expect(badges).to.include(':verified:')

      it 'responds to "what badges do I have"', ->
        @msg.match = [0, 'I']
        @robot.respond.args[3][1](@msg)
        expect(@msg.reply).to.have.been.calledWith(sinon.match(/You have (the following|no) badges.*/))

      it 'responds to "what badges does sinon2 have"', ->
        @msg.match = [0, 'sinon2']
        @robot.respond.args[3][1](@msg)
        expect(@msg.reply).to.have.been.calledWith(sinon.match(/sinon2 has (the following|no) badges.*/))

      it 'responds to "I don\'t have the founder badge"', ->
        @msg.match = [0, 'I', 'founder']
        @robot.respond.args[4][1](@msg)
        badges = @data.ingressBadges.U123
        expect(@msg.reply).to.have.been.calledWith('removed the :founder: badge')
        expect(badges).not.to.include(':founder:')
