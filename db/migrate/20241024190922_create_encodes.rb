class CreateEncodes < ActiveRecord::Migration[7.2]
  def change
    create_table :encodes do |t|
      t.string :name
      t.string :encode_type
      t.string :custom_id
      t.json :custom_data
      t.string :status
      t.timestamps
    end
  end
end