# frozen_string_literal: true

module Utils
  module Repository
    module Errors
      class Error < StandardError
      end

      class ValidationError < Error
        attr_reader :detailed_errors

        def initialize(message=nil)
          super(message)
          build_detailed_errors(message)
        end

        private

        def build_detailed_errors(message)
          return unless message.is_a?(ActiveRecord::RecordInvalid)
          return if message.record.blank?
          # It's important to use `to_hash`, as ActiveModel::Errors is using
          # some default_proc for the hashes, which can break logic of dig/present/[] methods
          # this is fixed in newer versions of rails
          @detailed_errors = message.record.errors.to_hash
        end
      end

      class NotFoundError < Error
      end

      class UnauthorizedError < Error
      end

      # Intercepts activerecord errors and produces its own ones so
      # Rails(AR) errors are not exposed outside of repository context.
      def wrap_activerecord_errors
        yield
      rescue ActiveRecord::RecordInvalid => e
        raise ValidationError, e
      rescue ActiveRecord::RecordNotFound => e
        raise NotFoundError, e
      rescue ActiveRecord::ActiveRecordError => e
        raise Error, e
      end

      def raise_not_found!(entity, params)
        params_str = params.map { |k, v| "#{k} = #{v}" }.join(", ")
        message = "#{entity} with #{params_str} not found"
        raise NotFoundError.new(message)
      end

      def raise_precondition_failed!(message)
        raise ValidationError.new(message)
      end
    end
  end
end
