# frozen_string_literal: true

require_relative './api/errors/error_object'

module Utils
  # Interactor
  #
  # A concept is taken from hanami framework https://guides.hanamirb.org/architecture/interactors/
  module Interactor
    # Result of an operation
    class Result
      METHODS = ::Hash[initialize: true,
                       success?: true,
                       successful?: true,
                       failure?: true,
                       fail!: true,
                       prepare!: true,
                       errors: true,
                       error: true].freeze

      # Initialize a new result
      #
      # @param payload [Hash] a payload to carry on
      #
      # @return [Interactor::Result]
      def initialize(payload = {})
        @payload = payload
        @errors  = []
        @success = true
      end

      # Check if the current status is successful
      #
      # @return [TrueClass,FalseClass] the result of the check
      def success?
        @success && errors.empty?
      end

      alias successful? success?

      # Check if the current status is not successful
      #
      # @return [TrueClass,FalseClass] the result of the check
      def failure?
        !success?
      end

      # Force the status to be a failure
      def fail!
        @success = false
      end

      # Returns all the errors collected during an operation
      #
      # @return [Array] the errors
      attr_reader :errors

      # Adds an error to the errors list
      def add_error(*errors)
        errors.map! do |error|
          if error.is_a?(Hash) && error.key?(:title) && error.key?(:source)
            Utils::Api::Errors::ErrorObject.new(error)
          else
            error
          end
        end

        @errors << errors
        @errors.flatten!
        nil
      end

      # Prepare the result before to be returned
      #
      # @param payload [Hash] an updated payload
      # @return [Interactor::Result]
      def prepare!(payload)
        @payload.merge!(payload)
        self
      end

      private

      def method_missing(method_name, *)
        @payload.fetch(method_name) { super }
      end

      def respond_to_missing?(method_name, _include_all)
        method_name = method_name.to_sym
        METHODS[method_name] || @payload.key?(method_name)
      end
    end

    def self.included(base)
      super

      base.class_eval do
        extend ClassMethods
        class_attribute :entity
      end
    end

    module Interface
      # Triggers the operation and return a result.
      #
      # All the exposed instance variables will be available in the result.
      #
      # @return [Interactor::Result] the result of the operation
      #
      # @raise [NoMethodError] if this isn't implemented by the including class.
      #
      # @example Expose instance variables in result payload
      #   require 'interactor'
      #
      #   class Signup
      #     include Interactor
      #     expose :user, :params
      #
      #     def call(params)
      #       @params = params
      #       @foo = 'bar'
      #       @user = UserRepository.new.persist(User.new(params))
      #     end
      #   end
      #
      #   result = Signup.new(name: 'Luca').call
      #   result.failure? # => false
      #   result.successful? # => true
      #
      #   result.user   # => #<User:0x007fa311105778 @id=1 @name="Luca">
      #   result.params # => { :name=>"Luca" }
      #   result.foo    # => raises NoMethodError
      #
      # @example Failed precondition
      #   require 'interactor'
      #
      #   class Signup
      #     include Interactor
      #     expose :user
      #
      #     # THIS WON'T BE INVOKED BECAUSE #valid? WILL RETURN false
      #     def call(params)
      #       @user = User.new(params)
      #       @user = UserRepository.new.persist(@user)
      #     end
      #
      #     private
      #
      #     def valid?(params)
      #       params.valid?
      #     end
      #   end
      #
      #   result = Signup.new.call(name: nil)
      #   result.successful? # => false
      #   result.failure? # => true
      #
      #   result.user   # => nil
      def call(*args)
        @__result = Result.new
        _call(*args) { super }
      end

      private

      def _call(*args)
        catch :fail do
          validate!(*args)
          yield
        end

        _prepare!
      end

      def validate!(*args)
        fail! unless valid?(*args)
      end
    end

    module ClassMethods
      def self.extended(interactor)
        interactor.class_eval do
          class_attribute :exposures
          self.exposures = {}
        end
      end

      def method_added(method_name)
        super
        return unless method_name == :call

        prepend Interface
      end

      # Expose local instance variables into the returning value of <tt>#call</tt>
      #
      # @param instance_variable_names [Symbol,Array<Symbol>] one or more instance
      #   variable names
      #
      # @example Expose instance variable
      #
      #   class Signup
      #     include Interactor
      #     expose :user
      #
      #     def initialize(params)
      #       @params = params
      #       @user   = User.new(@params[:user])
      #     end
      #
      #     def call
      #       # ...
      #     end
      #   end
      #
      #   result = Signup.new(user: { name: "Luca" }).call
      #
      #   result.user   # => #<User:0x007fa85c58ccd8 @name="Luca">
      #   result.params # => NoMethodError
      def expose(*instance_variable_names)
        instance_variable_names.each do |name|
          exposures[name.to_sym] = "@#{name}"
        end
      end
    end

    private

    # Check if proceed with #call invokation.
    # By default it returns true.
    #
    # @return [TrueClass,FalseClass] the result of the check
    def valid?(*)
      true
    end

    # Fail and interrupt the current flow.
    def fail!
      @__result.fail!
      throw :fail
    end

    # Log an error without interrupting the flow.
    #
    # When used, the returned result won't be successful.
    #
    # @param message [String] the error message
    def error(message)
      @__result.add_error(message)
    end

    # Log an error and interrupting the flow.
    #
    # When used, the returned result won't be successful.
    #
    # @param message [String] the error message
    def error!(message)
      error(message)
      fail!
    end

    def _prepare!
      @__result.prepare!(_exposures)
    end

    def _exposures
      Hash[].tap do |result|
        self.class.exposures.each do |name, ivar|
          result[name] = instance_variable_defined?(ivar) ? instance_variable_get(ivar) : nil
        end
      end
    end

    # Builds an entity based on given attributes
    #
    # @param attributes [Hash]
    #
    # @return an instance of entity which should be set as a class attribute
    def build_entity(attributes)
      self.class.entity.new(attributes)
    end
  end
end
