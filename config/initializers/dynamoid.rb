require 'dynamoid'

# credentials = Aws::AssumeRoleCredentials.new(
#   region: 'us-east-1',
#   access_key_id: 'AKIA4WEH4RYR7RSG76XI',
#   secret_access_key: '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',
#   role_arn: 'arn:aws:iam::872163348003:role/dynamodb-role',
#   role_session_name: 'rails-serverless-lambda'
# )

# puts "credentiall---"
# puts credentials

Dynamoid.configure do |config|
  config.region = 'us-east-1'
  # config.credentials = credentials
  config.namespace = nil
  config.endpoint = 'https://dynamodb.us-east-1.amazonaws.com'
end
