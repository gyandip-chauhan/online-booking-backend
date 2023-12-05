class CreateSeatCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :seat_categories do |t|
      t.string :name
      t.integer :start_num_of_seat
      t.integer :end_num_of_seat
      t.string :seats
      t.bigint :price

      t.timestamps
    end
    add_reference :seat_categories, :screen, foreign_key: true
    add_reference :seat_categories, :theater, foreign_key: true
    add_reference :seat_categories, :movie, foreign_key: true
  end
end
