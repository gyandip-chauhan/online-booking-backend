class Booking < ApplicationRecord
  has_paper_trail
  belongs_to :user
  belongs_to :showtime
  has_one :movie, through: :showtime
  has_one :theater, through: :showtime
  has_many :booked_seats, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    %w[id movie.title theater.name theater.location created_at updated_at user.email user.username seats]
  end
end
