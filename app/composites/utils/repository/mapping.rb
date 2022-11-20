# frozen_string_literal: true

module Utils
  module Repository
    module Mapping
      module ClassMethods
        def self.extended(repository)
          repository.class_eval do
            class_attribute :entity_attributes_map
            self.entity_attributes_map = {}
          end
        end

        # Maps the attributes of the given entity to db columns
        #
        # @param attribute_name [Symbol]
        # @param activerecord_class [Class]
        # @param activerecord_attribute [Symbol]
        # @param mapper - an optional argument. It must have two public methods:
        #   - entity_value - receives AR value and maps it to entity value
        #   - activerecord_value - receives entity value and maps it to AR value
        #
        # @example Map attributes of aggregated Customer model
        #   require 'repository'
        #
        #   class CustomerRepository
        #     include Repository
        #
        #     map_attribute :id, Mandate, :id
        #     map_attribute :mandate_state, Mandate, :state, Mappings::MandateState
        #     map_attribute :customer_state, Mandate, :customer_state
        #
        #     map_attribute :registered_with_ip, Lead, :registered_with_ip
        #     map_attribute :source_data, Lead, :source_data
        #   end
        def map_attribute(attribute_name, activerecord_class, activerecord_attribute, mapper=nil)
          entity_attributes_map[attribute_name] = {
            activerecord_class: activerecord_class,
            activerecord_attribute: activerecord_attribute,
            mapper: mapper
          }
        end

        # Maps the attributes with block of the given entity to db columns
        #
        # @param attribute_name [Symbol]
        # @param activerecord_class [Class]
        # @param activerecord_attribute [Symbol]
        # @param block - lambda object
        #
        # @example Map attributes of aggregated Customer model
        #   require 'repository'
        #
        #   class CustomerRepository
        #     include Repository
        #
        #     map_attribute_with :id, Mandate, :itself, lambda { |obj| obj.id }
        #     map_attribute_with :mandate_state, Mandate, :itself, lambda { |obj| obj.state }
        #   end

        def map_attribute_with(attribute_name, activerecord_class, activerecord_attribute, block)
          entity_attributes_map[attribute_name] = {
            activerecord_class: activerecord_class,
            activerecord_attribute: activerecord_attribute,
            mapper: nil,
            block: block
          }
        end
      end

      private

      # Maps the attributes from given array of activerecord models to
      # the entity attributes.
      # @param models [Array<ActiveRecord::Base>]
      #
      # @return an instance of entity which should be set as a class attribute
      def entity_attributes(*activerecords, options: {})
        attributes = {}
        self.class.entity_attributes_map.each do |attribute, ar|
          model = activerecords.find do |m|
            if ar[:activerecord_class].is_a?(Array)
              ar[:activerecord_class].include? m.class
            else
              m.class.to_s == ar[:activerecord_class].to_s
            end
          end

          next unless model.respond_to?(ar[:activerecord_attribute])
          value = model.public_send(ar[:activerecord_attribute])
          if ar[:block].present?
            attributes[attribute] = options.present? ? ar[:block].call(value, options) : ar[:block].call(value)
            next
          end
          attributes[attribute] = ar[:mapper] ? ar[:mapper].entity_value(value) : value
        end
        attributes
      end

      # Maps the attributes of entity to activerecord attributes
      # Use activerecord_class param to get class specific AR attributes
      # @param entity_attributes [Hash]
      # @param activerecord_class [Class]
      #
      # @return [Hash] attributes of AR model
      def activerecord_attributes(entity_attributes, activerecord_class=nil)
        attributes = {}
        entity_attributes.each do |key, value|
          config = self.class.entity_attributes_map[key.to_sym]
          if config
            value = config[:mapper].activerecord_value(value) if config[:mapper]
            next if activerecord_class && activerecord_class.to_s != config[:activerecord_class].to_s
            attributes[config[:activerecord_attribute]] = value
          else
            attributes[key] = value
          end
        end
        attributes
      end
    end
  end
end
