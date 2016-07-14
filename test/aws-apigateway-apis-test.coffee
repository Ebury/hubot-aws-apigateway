AWS = require 'aws-sdk-mock'

Helper = require('hubot-test-helper')
helper = new Helper('../src/aws-apigateway.coffee')

chai = require('chai')
expect = chai.expect

AWS.mock('APIGateway', 'getRestApis', {items: [{id: '1234abcd', name: 'Unit Test API', description: 'An API for unit testing'}]})

describe 'List APIs', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  context 'user wants list of APIs', ->
    beforeEach ->
      @room.user.say 'user', '@hubot list apis'

    it 'hubot should respond with list of API keys', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot list apis']
        ['hubot', '@user \n**Unit Test API**: id = 1234abcd, description = An API for unit testing\n']
      ]
