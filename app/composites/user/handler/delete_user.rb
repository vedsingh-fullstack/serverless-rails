# frozen_string_literal: true

require_relative '../../../../config/environment'

$app = Rack::Builder.new { run Rails.application }.to_app

class Handler
  def self.process(event:, context:)
    path_params = event['pathParameters'].symbolize_keys

    User.delete_user(path_params[:user_id].to_i)

    {
      "statusCode": 200,
      "body": JSON.generate('User deleted Successfully'),
      "isBase64Encoded": false
    }
  end
end
