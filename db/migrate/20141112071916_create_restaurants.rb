class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :category
      t.string :address
      t.string :phone_number
      t.string :url
      t.string :venue_id

      t.timestamps
    end
  end
end
