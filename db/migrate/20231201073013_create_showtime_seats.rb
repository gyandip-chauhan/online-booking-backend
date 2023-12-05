class CreateShowtimeSeats < ActiveRecord::Migration[7.0]
  def change
    create_table :showtime_seats do |t|
      t.references :showtime, null: false, foreign_key: true
      t.string :seats
      t.references :seat_category, null: false, foreign_key: true

      t.timestamps
    end
    remove_column :showtimes, :available_seats, :integer
  end
end
