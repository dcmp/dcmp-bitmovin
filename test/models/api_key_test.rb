# == Schema Information
#
# Table name: api_keys
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  name        :string
#  secured_key :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_api_keys_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
require "test_helper"

class ApiKeyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
