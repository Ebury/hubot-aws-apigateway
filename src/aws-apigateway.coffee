# Description:
#  Maps chat onto AWS API Gateway functionality - API key functions
#
# Dependencies:
#   "<module name>": "<module version>"
#
# Configuration:
#   HUBOT_FLOWDOCK_LOGIN_EMAIL    : Email of the user who is the bot
#   HUBOT_FLOWDOCK_LOGIN_PASSWORD : Password of the user who is the bot
#
# Commands:
#   gateway list api keys - List all API keys for the gateway
#   gateway list api key <name> - List an API key with assigned APIs and stages
#   gateway create api key <name> - Create an API key with name of <name>
#   gateway [enable|disable] api key <name> - Enable or disable the API key with the name of <name>
#   gateway delete api key <name> - Delete the API key with the name of <name>, requires confirmation
#   gateway confirm delete api key <comma-separated key list> - Delete API keys in list
#   gateway assign <api key name> to <api name> for <stage name> stage - Assign an API key to an API for a given stage
#   gateway remove <api key name> from <api name> for <stage name> stage - Remove an API key from an API for a given stage
#
# Notes:
#   The script expects to find an AWS credentials file at ~/.aws/credentials, containing the API key and secret
#
# Author:
#   SensibleWood
AWS = require './aws-instance'

module.exports = (robot) ->
  # List all API Keys
  robot.respond /list api keys/i, (msg) ->
    AWS.APIGateway.getApiKeys (error, data) ->
      if error
        console.log error
        return msg.reply 'Error listing API keys, check the bot logs'

      else
        names = ('**' + k.name + '**: value = ' + k.id + ', enabled = **' + k.enabled + '**' for k in data.items)
        return msg.reply '\n' + names.join('\n') + '\n'

  # List an API Key with details
  robot.respond /list api key (.*)/i, (msg) ->
    AWS.APIGateway.getApiKeys (error, data) ->
      if error
        console.log error
        return msg.reply 'Could not fetch list of API keys'

      else
        api_key = null

        for k in data.items
          if k.name == msg.match[1]
            api_key = k.id

        if api_key == null
          return msg.reply 'Could not find API key: ' + msg.match[1]

        AWS.APIGateway.getRestApis (error, data) ->
          if error
            console.log error
            return msg.reply 'Error listing APIs, check the bot logs'

          else
            apis = {}

            for k in data.items
              apis[k.id] = k.name

            AWS.APIGateway.getApiKey {apiKey: api_key}, ((error, data) ->
              if error
                console.log error
                return msg.reply 'Error listing API keys, check the bot logs'

              else
                return msg.reply '**' + data.name + '**: value: ' + data.id + ', assigned APIs:' + \
                    ('\n* **' + apis[s.split('/')[0]] + '**, stage: **' + s.split('/')[1] + '**' for s in data.stageKeys)
            ).bind(apis: apis)


  # Create new DISABLED API Key
  robot.respond /create api key (.*)/i, (msg) ->
    AWS.APIGateway.createApiKey {name: msg.match[1], enabled: false}, (error, data) ->
      if error
        console.log(error);
        return msg.reply 'Error creating API key, check the bot logs'

      else
        return msg.reply 'Created key: ' + data.id

  # Start the process of deleting API keys with name
  robot.respond /delete api key (.*)/i, (msg) ->
    AWS.APIGateway.getApiKeys (error, data) ->
      if error
        console.log error

      else
        keys = []

        for k in data.items
          if k.name == msg.match[1]
            keys.push k.id

        if keys.length == 0
          return msg.reply 'No keys found matching **' + msg.match[1] + '**'

        else
          return msg.reply 'Confirm delete by entering: **' + robot.name + ' confirm delete api key ' + keys.join(',') + '**'

  # Confirm delete of API keys
  robot.respond /confirm delete api key (.*)/i, (msg) ->
    keys = msg.match[1].split(',')

    for k in keys
      AWS.APIGateway.deleteApiKey {apiKey: k}, ((error, data) ->
        if error
          console.log error
          return msg.reply 'Error deleting key: ' + this.api_key

        else
          return msg.reply 'Deleted key: ' + this.api_key

      ).bind { api_key: k }

  # Enable/disable API Key
  robot.respond /(enable|disable) api key (.*)/i, (msg) ->
    request = AWS.APIGateway.getApiKeys()
    promise = request.promise()

    promise.then(
      (data) ->
        enabled = {enable: 'true', disable: 'false'}[msg.match[1]]

        for k in data.items
          if k.name == msg.match[2]
            params = {apiKey: k.id, patchOperations: [{op: 'replace', path: '/enabled', value: enabled}]}
            AWS.APIGateway.updateApiKey params, (error, data) ->
                if error
                  console.log error
                  return msg.reply 'Error updating API key to ' + msg.match[1] + ': ' + msg.match[2]

                else
                  return msg.reply 'Updated API key: ' + msg.match[2] + ', new status: ' + msg.match[1]
      (error) ->
        console.log error
        return msg.reply 'Error updating API key to ' + msg.match[1] + ': ' + msg.match[2]
    )

  # Assign/Remove an API key to/from an API for a given stage
  robot.respond /(assign|remove) (.*) (to|from) (.*) for (.*) stage/i, (msg) ->
    operation = {assign: 'add', remove: 'remove'}[msg.match[1]]

    AWS.APIGateway.getApiKeys (error, data) ->
      if error
        console.log error
        return msg.reply 'Could not fetch list of API keys'

      else
        api_key = null
        rest_api = null

        for k in data.items
          if k.name == msg.match[2]
            api_key = k.id

        if api_key == null
          return msg.reply('API key not found: ' + msg.match[2])

        AWS.APIGateway.getRestApis (error, data) ->
          if error
            console.log error
            return msg.reply 'Could not fetch list of API keys'

          else
            for k in data.items
              if k.name == msg.match[4]
                rest_api = k.id

            if rest_api == null
              return msg.reply('API not found: ' + msg.match[4])

            params = {apiKey: api_key, patchOperations: [{op: operation, path: '/stages', value: rest_api + '/' + msg.match[5]}]}
            AWS.APIGateway.updateApiKey params, (error, data) ->
              if error
                console.log error
                return msg.reply 'Could not update API key: ' + msg.match[2]

              else
                return msg.reply 'Operation <' + operation + '> for **' + msg.match[4] + '** successful: ' + msg.match[2]

  robot.respond /list apis/i, (msg) ->
    AWS.APIGateway.getRestApis (error, data) ->
      if error
        console.log error
        return msg.reply 'Error listing APIs, check the bot logs'

      else
        names = ('**' + k.name + '**: id = ' + k.id + ', description = ' + k.description for k in data.items)
        return msg.reply '\n' + names.join('\n') + '\n'
