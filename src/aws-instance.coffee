AWS = require('aws-sdk')

credentials = new AWS.SharedIniFileCredentials {profile: 'default'}

exports.APIGateway = new AWS.APIGateway({
  region: 'eu-west-1',
  credentials: credentials
})
