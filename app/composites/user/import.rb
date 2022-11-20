# frozen_string_literal: true

require_relative "container"

module User
  Import = Dry::AutoInject(User::Container)
end
