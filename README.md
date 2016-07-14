# hubot-aws-apigateway

Helps manage the AWS API Gateway

See [`src/aws-apigateway.coffee`](src/aws-apigateway.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-aws-apigateway --save`

Then add **hubot-aws-apigateway** to your `external-scripts.json`:

```json
[
  "hubot-aws-apigateway"
]
```

## Sample Interaction

```
user1>> hubot list api keys
hubot>> **Example API Key**: id = abcd1234, enabled = **false**
```

