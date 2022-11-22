# frozen_string_literal: true

require_relative '../../../../config/environment'

$app = Rack::Builder.new { run Rails.application }.to_app

class Handler
  def self.process(event:, context:)
    path_params = event["pathParameters"].symbolize_keys
    event_body = JSON.parse(event['body']).symbolize_keys

    User.update_user(path_params[:user_id].to_i, event_body)

    {
      "statusCode": 200,
      "body": JSON.generate("User Updated Successfully"),
      "isBase64Encoded": false
    }
  end
end
