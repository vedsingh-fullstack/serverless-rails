# frozen_string_literal: true

module Utils
  module CompositeFacade
    def public_interactor(interactor, &block)
      method_desc = MethodDescription.new
      method_desc.instance_eval(&block)

      define_singleton_method(interactor) do |*args|
        args.each_with_index do |arg, i|
          validate_type!(arg, method_desc.params[i][1]) if method_desc.params[i][1]
        end

        container.resolve("public.interactors.#{interactor}").call(*args)
      end
    end

    private

    class MethodDescription
      attr_reader :params

      def initialize
        @params = []
      end

      def param(name, type: nil, desc: "")
        @params << [name, type, desc]
      end
    end

    def container
      raise NotImplementedError
    end

    def validate_type!(arg, type)
      return if arg.instance_of?(type)
      error = "argument #{arg} doesn't match type #{type}"
      raise ArgumentError.new(error)
    end
  end
end
