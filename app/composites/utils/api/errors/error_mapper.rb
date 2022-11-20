# frozen_string_literal: true

module Utils
  module Api
    module Errors
      class ErrorMapper
        class << self
          # @param errors [Hash]
          # @return [Array] array of Utils::Api::Errors::ErrorObject
          def call(errors)
            errors.map { |key, value| ErrorObject.new(title: value.first, source: { pointer: key }) }
          end
        end
      end
    end
  end
end
