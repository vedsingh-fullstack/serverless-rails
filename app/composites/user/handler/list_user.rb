# frozen_string_literal: true

require_relative '../../../../config/environment'

$app = Rack::Builder.new { run Rails.application }.to_app

class Handler
  def self.process(event:, context:)
    users = User.list_user

    {
      "statusCode": 200,
      "body": JSON.generate(users.users_payload),
      "isBase64Encoded": false
    }
  end
end
