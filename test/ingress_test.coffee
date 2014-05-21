chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'ingress', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/ingress')(@robot)

  describe 'respond listener', ->

    it 'registers AP per level response', ->
      expect(@robot.respond).to.have.been.calledWith(/AP\s+(?:to|(?:un)?til)\s+L?(\d{1,2})/i)

    it 'registers AP for all levels response', ->
      expect(@robot.respond).to.have.been.calledWith(/AP all/i)
