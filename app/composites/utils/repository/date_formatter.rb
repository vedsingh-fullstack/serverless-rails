# frozen_string_literal: true

module Utils
  module Repository
    module DateFormatter
      class << self
        def entity_value(field)
          field.iso8601.to_s
        end
      end
    end
  end
end
