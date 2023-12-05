class CreateBookedSeats < ActiveRecord::Migration[7.0]
  def change
    create_table :booked_seats do |t|
      t.references :seat_category, null: false, foreign_key: true
      t.references :booking, null: false, foreign_key: true
      t.string :seats
      t.bigint :price

      t.timestamps
    end
    remove_column :bookings, :seats, :string
    add_column :bookings, :total_price, :bigint
  end
end
