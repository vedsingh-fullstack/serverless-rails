# frozen_string_literal: true

module User
  module Entities
    class CustomerData < Dry::Struct
      # attribute :user_id, Types::Strict::Integer
      attribute :email, Types::Strict::String
      attribute :first_name, Types::Strict::String
      attribute :last_name, Types::Strict::String
    end
  end
end
