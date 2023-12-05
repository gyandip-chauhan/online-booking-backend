class CreateRatings < ActiveRecord::Migration[7.0]
  def change
    create_table :ratings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :rateable, polymorphic: true, null: false
      t.integer :value

      t.timestamps
    end
  end
end
