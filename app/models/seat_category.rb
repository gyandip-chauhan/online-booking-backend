class SeatCategory < ApplicationRecord
  belongs_to :screen
  belongs_to :theater
  belongs_to :movie
  has_many :showtime_seats, dependent: :destroy
  has_many :booked_seats, dependent: :destroy

  validates :start_num_of_seat, :end_num_of_seat, :price, :screen_id, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[id name screen.name movie.title theater.name seats price created_at updated_at showtime_seats.seats]
  end

  def self.ransackable_associations(auth_object = nil)
    ["screen", "theater", "movie", "showtime_seats", "booked_seats"]
  end
end
