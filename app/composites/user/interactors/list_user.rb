# frozen_string_literal: true

require_relative "../../utils/interactor"
require_relative "../import"

module User
  module Interactors
    class ListUser
      include Utils::Interactor

      include Import[
        user_repository: "repositories.user_repository",
      ]

      expose :users_payload

      def call
        @users_payload = user_repository.get
      end
    end
  end
end
