# frozen_string_literal: true

require 'json'

require_relative './error_object'

module Utils
  module Api
    module Errors
      module JsonApiFormatter
        class << self
          # @param message [String | Hash | Array<String> | Array<Hash>]
          # @param status [Integer]
          def call(message, backtrace, options = {}, _env = nil, original_exception = nil)
            message = message[:errors] if message.is_a?(Hash) && message.key?(:errors)

            result = {}
            rescue_options = options[:rescue_options] || {}
            result = result.merge(backtrace: backtrace) if rescue_options[:backtrace] && backtrace && !backtrace.empty?
            if rescue_options[:original_exception] && original_exception
              result = result.merge(original_exception: original_exception.inspect)
            end

            JSON.dump result.merge(errors: formatter(message))
          end

          private

          # Follow JSON API standard https://jsonapi.org/format/#errors
          #
          # @param message [String | Array<String> | Array<Hash> | Array<ErrorObject>]
          # @return [Array<Hash>] a format compatible to JSON API errors
          # https://jsonapi.org/format/#errors
          def formatter(message)
            case message
            when ErrorObject then [message.to_hash]
            when String then [{ title: message }]
            when Array
              message.map(&method(:normalize))
            when Hash
              # Flatten message from app/api/clark_api/msg_rescuable.rb
              message = message[:api] if message.dig(:api)
              message.map { |key, msg| normalize(msg).merge(code: key) }
            else
              message
            end
          end

          # @param error [String | Hash | ErrorObject]
          # @return [Hash]
          def normalize(message)
            case message
            when Hash
              {}.tap do |result|
                result[:title] = message[:message] if message[:message].is_a?(String)
                result[:meta] = { data: message.except(:message) }
              end
            when String then { title: message }
            when ErrorObject then message.to_hash
            when Array then { title: message.first }
            else
              message
            end
          end
        end
      end
    end
  end
end
