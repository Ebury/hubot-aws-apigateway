AWS = require 'aws-sdk-mock'

Helper = require('hubot-test-helper')
helper = new Helper('../src/aws-apigateway.coffee')

chai = require('chai')
expect = chai.expect

AWS.mock('APIGateway', 'getApiKeys', {items: [name: "Unit Test", id: "abcd1234", enabled: false]})
AWS.mock('APIGateway', 'getApiKey', {id: "abcd1234", name: "Unit Test", stageKeys: [ '1234abcd/demo' ]})
AWS.mock('APIGateway', 'getRestApis', {items: [id: '1234abcd', name: 'Unit Test API']})

describe 'List API Keys', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  context 'user wants list of API keys', ->
    beforeEach ->
      @room.user.say 'user', '@hubot list api keys'

    it 'hubot should respond with list of API keys', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot list api keys']
        ['hubot', '@user \n**Unit Test**: value = abcd1234, enabled = **false**\n']
      ]

  context 'user wants one API key and all its details', ->
    beforeEach ->
      @room.user.say 'user', '@hubot list api key Unit Test'

    it 'hubot should respond with details of API key', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot list api key Unit Test']
        ['hubot', '@user **Unit Test**: value: abcd1234, assigned APIs:\n* **Unit Test API**, stage: **demo**']
      ]

  context 'user wants one API key that does not exist', ->
    beforeEach ->
      @room.user.say 'user', '@hubot list api key Unknown Unit Test'

    it 'hubot should respond with details of API key', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot list api key Unknown Unit Test']
        ['hubot', '@user Could not find API key: Unknown Unit Test']
      ]
