# frozen_string_literal: true

require_relative '../../../../config/environment'

$app = Rack::Builder.new { run Rails.application }.to_app

class Handler
  def self.process(event:, context:)
    puts 'Events logged----'
    puts event

    puts 'Context-----'
    puts context

    puts 'event body-'
    puts event['body']

    data = JSON.parse(event['body']).symbolize_keys

    User.create_user(data)

    {
      "statusCode": 200,
      "headers": {
        "my_header": 'my_value'
      },
      "body": JSON.generate(data),
      "isBase64Encoded": false
    }
  end
end
