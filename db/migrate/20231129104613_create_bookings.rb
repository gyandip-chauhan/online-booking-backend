class CreateBookings < ActiveRecord::Migration[7.0]
  def change
    create_table :showtimes do |t|
      t.references :movie, null: false, foreign_key: true
      t.references :theater, null: false, foreign_key: true
      t.datetime :time
      t.string :available_seats

      t.timestamps
    end

    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :showtime, null: false, foreign_key: true
      t.string :seats

      t.timestamps
    end
  end
end
