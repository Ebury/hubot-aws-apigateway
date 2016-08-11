AWS = require 'aws-sdk-mock'

Helper = require('hubot-test-helper')
helper = new Helper('../src/aws-apigateway.coffee')

chai = require('chai')
expect = chai.expect

AWS.mock('APIGateway', 'createApiKey', {id: "efgh5678", name: "New Unit Test API Key"})
AWS.mock('APIGateway', 'getApiKeys', {items: [name: "New Unit Test API Key", id: "efgh5678", enabled: false]})
AWS.mock('APIGateway', 'updateApiKey', {error: {}})
AWS.mock('APIGateway', 'deleteApiKey', {})
AWS.mock('APIGateway', 'getRestApis', {items: [{id: '1234abcd', name: 'Unit Test API 1'}, {id: '5678efgh', name: 'Unit Test API 2'}]})


describe 'Create API Key', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  context 'user wants to create a new API key', ->
    beforeEach ->
      @room.user.say 'user', '@hubot create api key New Unit Test API Key'

    it 'hubot should respond with new API key', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot create api key New Unit Test API Key']
        ['hubot', '@user Created key: efgh5678']
      ]

describe 'Change status of API Key', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  context 'user wants to enable API key', ->
    beforeEach ->
      @room.user.say 'user', '@hubot enable api key New Unit Test API Key'

    it 'hubot should enable API key', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot enable api key New Unit Test API Key']
        ['hubot', '@user Updated API key: New Unit Test API Key, new status: enable']
      ]

  context 'user wants to disable API key', ->
    beforeEach ->
      @room.user.say 'user', '@hubot disable api key New Unit Test API Key'

    it 'hubot should disable API key', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot disable api key New Unit Test API Key']
        ['hubot', '@user Updated API key: New Unit Test API Key, new status: disable']
      ]

describe 'Delete API Key', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  context 'user wants to delete an API key', ->
    beforeEach ->
      @room.user.say 'user', '@hubot delete api key New Unit Test API Key'

    it 'hubot should prompt user to confirm deletion', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot delete api key New Unit Test API Key']
        ['hubot', '@user Confirm delete by entering: **hubot confirm delete api key efgh5678**']
      ]

  context 'user confirms deletion of API key', ->
    beforeEach ->
      @room.user.say 'user', '@hubot confirm delete api key efgh5678'

    it 'hubot should confirm deletion', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot confirm delete api key efgh5678']
        ['hubot', '@user Deleted key: efgh5678']
      ]

describe 'Change assignment of API key to API', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  context 'user wants to assign API key to API for demo stage', ->
    beforeEach ->
      @room.user.say 'user', '@hubot assign New Unit Test API Key to Unit Test API 1 for demo stage'

    it 'hubot should assign the API key to the requested API for the demo stage', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot assign New Unit Test API Key to Unit Test API 1 for demo stage']
        ['hubot', '@user Operation <add> for **Unit Test API 1** successful: New Unit Test API Key']
      ]

  context 'user wants to assign API key to APIs for demo stage using a regular expression', ->
    beforeEach ->
      @room.user.say 'user', '@hubot assign New Unit Test API Key to Unit Test API.*? for demo stage'

    it 'hubot should assign the API key to the requested API for the demo stage', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot assign New Unit Test API Key to Unit Test API.*? for demo stage']
        ['hubot', '@user Operation <add> for **Unit Test API 1** successful: New Unit Test API Key']
        ['hubot', '@user Operation <add> for **Unit Test API 2** successful: New Unit Test API Key']
      ]

  context 'user wants to remove API key from API for demo stage', ->
    beforeEach ->
      @room.user.say 'user', '@hubot remove New Unit Test API Key from Unit Test API 1 for demo stage'

    it 'hubot should remove the API key from the requested API for the demo stage', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot remove New Unit Test API Key from Unit Test API 1 for demo stage']
        ['hubot', '@user Operation <remove> for **Unit Test API 1** successful: New Unit Test API Key']
      ]

  context 'user wants to remove API key from APIs for demo stage', ->
    beforeEach ->
      @room.user.say 'user', '@hubot remove New Unit Test API Key from Unit Test API.*? for demo stage'

    it 'hubot should remove the API key from the requested API for the demo stage', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot remove New Unit Test API Key from Unit Test API.*? for demo stage']
        ['hubot', '@user Operation <remove> for **Unit Test API 1** successful: New Unit Test API Key']
        ['hubot', '@user Operation <remove> for **Unit Test API 2** successful: New Unit Test API Key']
      ]

  context 'user wants to assign API key to unknown API', ->
    beforeEach ->
      @room.user.say 'user', '@hubot assign New Unit Test API Key to Unknown Unit Test API for demo stage'

    it 'hubot should return an unknown API message', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot assign New Unit Test API Key to Unknown Unit Test API for demo stage']
        ['hubot', '@user API not found: Unknown Unit Test API']
      ]

  context 'user wants to assign unknown API key to API', ->
    beforeEach ->
      @room.user.say 'user', '@hubot assign Unknown Unit Test API Key to Unit Test API for demo stage'

    it 'hubot should return an unknown API key message', ->
      expect(@room.messages).to.eql [
        ['user', '@hubot assign Unknown Unit Test API Key to Unit Test API for demo stage']
        ['hubot', '@user API key not found: Unknown Unit Test API Key']
      ]

# TODO: Need to figure out how to successfully mock a test where the stage is unknown
