# frozen_string_literal: true

require_relative '../../utils/interactor'
require_relative '../import'

module User
  module Interactors
    class UpdateUser
      include Utils::Interactor

      include Import[
        user_repository: 'repositories.user_repository',
      ]

      expose :users_payload

      def call(user_id, data)
        @users_payload = user_repository.update(user_id, data)
      end
    end
  end
end
