# frozen_string_literal: true

require_relative '../../utils/repository'
require_relative '../entities/customer_data'

module User
  module Repositories
    class UserRepository
      include Utils::Repository

      self.entity = User::Entities::CustomerData

      # map_attribute :user_id, ::CustomerData, :user_id
      map_attribute :email, ::Customer, :email
      map_attribute :first_name, ::Customer, :first_name
      map_attribute :last_name,  ::Customer, :last_name

      def create(user_data)
        Rails.logger.info 'user_data'
        Rails.logger.info user_data

        Customer.create(first_name: user_data[:first_name], last_name: user_data[:last_name], email: user_data[:email],
                        created_at: Time.now, updated_at: Time.now)
      end

      def get
        records = []
        Customer.record_limit(10_000).batch(100).each do |customer|
          records.push(customer.attributes)
        end
        records
      end

      def update(email)
        customer = Customer.where(email: email)

        customer.update!
      end

      def delete_user(email)
        customer = Customer.where(email: email)
        customer.destroy!
      end
    end
  end
end
