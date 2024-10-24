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
class Encode < ApplicationRecord
end
