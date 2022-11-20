# frozen_string_literal: true

require_relative 'repository/errors'
require_relative 'repository/transaction'
require_relative 'repository/mapping'

module Utils
  module Repository
    include Utils::Repository::Errors
    include Utils::Repository::Mapping
    extend Utils::Repository::Transaction

    def self.included(base)
      super

      base.class_eval do
        extend ClassMethods
        extend Utils::Repository::Mapping::ClassMethods
        extend Utils::Repository::Transaction
      end
    end

    module ClassMethods
      def self.extended(repository)
        repository.class_eval do
          class_attribute :entity
        end
      end
    end

    # Builds an entity based on given attributes
    #
    # @param attributes [Hash]
    #
    # @return an instance of entity which should be set as a class attribute
    def build_entity(attributes)
      puts "inside here------"
      self.class.entity.new(attributes)
    end

    private

    # Builds an entity based on given attributes and entity
    #
    # @param attributes [Hash, entity]
    #
    # @return an instance of entity which should be set as a class attribute
    def build_custom_entity(attributes, entity_template: self.class.entity)
      entity_template.new(attributes)
    end
  end
end
