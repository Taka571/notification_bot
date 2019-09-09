class CreateRestaurants < ActiveRecord::Migration[5.2]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :url
      t.string :image
      t.string :place
      t.date :open_date
      t.timestamps
    end
  end
end
  
