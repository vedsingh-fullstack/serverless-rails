# frozen_string_literal: true

require_relative '../../utils/interactor'
require_relative '../import'

module User
  module Interactors
    class DeleteUser
      include Utils::Interactor

      include Import[
        user_repository: 'repositories.user_repository',
      ]

      def call(user_id)
        user_repository.delete_user(user_id)
      end
    end
  end
end
