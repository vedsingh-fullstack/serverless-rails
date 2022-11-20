# frozen_string_literal: true

module Utils
  module Repository
    module Transaction
      # Evaluates given block within a db transaction.
      def transaction(&block)
        ActiveRecord::Base.transaction(&block)
      end
    end
  end
end
