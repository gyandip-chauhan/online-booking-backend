class Theater < ApplicationRecord
  has_many :showtimes, dependent: :destroy
  has_many :movies, through: :showtimes
  has_many :seat_categories, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :ratings, as: :rateable

  validates :name, :location, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[id name location seats created_at updated_at ratings.value showtimes.movie.title showtimes.datetime seat_categories.seats]
  end

  def self.ransackable_associations(auth_object = nil)
    ["ratings", "showtimes", "seat_categories"]
  end
end
