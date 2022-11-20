# frozen_string_literal: true

require_relative "../../utils/interactor"
require_relative "../import"

module User
  module Interactors
    class CreateUser
      include Utils::Interactor

      include Import[
        user_repository: "repositories.user_repository",
      ]

      def call(data)
        user_repository.create(data)
      end
    end
  end
end
