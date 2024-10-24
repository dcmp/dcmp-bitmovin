# == Schema Information
#
# Table name: encodes
#
#  id          :integer          not null, primary key
#  name        :string
#  encode_type :string
#  custom_id   :string
#  custom_data :json
#  status      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "test_helper"

class EncodeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
