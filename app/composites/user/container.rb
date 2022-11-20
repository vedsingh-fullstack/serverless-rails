# frozen_string_literal: true

module User
  class Container
    puts "here-----"
    extend Dry::Container::Mixin

    namespace(:public) do
      namespace(:interactors) do
        register(:create_user) {
          User::Interactors::CreateUser.new
        }

        register(:list_user) {
            User::Interactors::ListUser.new
          }
      end
    end

    namespace(:repositories) do
      register(:user_repository) {
        User::Repositories::UserRepository.new
      }
    end
  end
end

require_relative "interactors/create_user"
require_relative "interactors/list_user"
require_relative "repositories/user_repository"
