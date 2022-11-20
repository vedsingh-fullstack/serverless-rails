# frozen_string_literal: true

class Customer
  include Dynamoid::Document

  table name: :users, key: :user_id, read_capacity: 5, write_capacity: 5

  field :user_id, :integer
  field :first_name, :string
  field :last_name, :string
  field :email, :string
  field :created_at, :datetime
  field :updated_at, :datetime
end
