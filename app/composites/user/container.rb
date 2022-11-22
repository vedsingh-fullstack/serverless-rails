# frozen_string_literal: true

module User
  class Container
    extend Dry::Container::Mixin

    namespace(:public) do
      namespace(:interactors) do
        register(:create_user) do
          User::Interactors::CreateUser.new
        end

        register(:list_user) do
          User::Interactors::ListUser.new
        end

        register(:update_user) do
          User::Interactors::UpdateUser.new
        end

        register(:delete_user) do
          User::Interactors::DeleteUser.new
        end
      end
    end

    namespace(:repositories) do
      register(:user_repository) do
        User::Repositories::UserRepository.new
      end
    end
  end
end

require_relative 'interactors/create_user'
require_relative 'interactors/list_user'
require_relative 'interactors/update_user'
require_relative 'interactors/delete_user'
require_relative 'repositories/user_repository'
