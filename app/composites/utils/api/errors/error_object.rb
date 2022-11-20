# frozen_string_literal: true

require_relative "../../../../../config/initializers/dry_types"

module Utils
  module Api
    module Errors
      class ErrorObject < Dry::Struct
        attribute :title, Types::Strict::String
        attribute? :detail, Types::Strict::String
        attribute? :source, Types::Strict::Hash
        attribute? :meta, Types::Strict::Hash
      end
    end
  end
end
