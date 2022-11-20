# frozen_string_literal: true

require_relative "utils/composite_facade"
require_relative "user/container"

module User
  extend Utils::CompositeFacade

  # @return [Concerns::Interactors::Result]
  public_interactor :create_user do
    param :data, type: Hash
  end

  public_interactor :list_user do; end

  class << self
    private

    def container
      User::Container
    end
  end
end
