class AddShowtimesCountToMovie < ActiveRecord::Migration[7.0]
  def change
    add_column :movies, :showtimes_count, :integer, default: 0

    Movie.find_each do |movie|
      Movie.reset_counters(movie.id, :showtimes)
    end
  end
end
