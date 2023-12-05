class Movie < ApplicationRecord
  belongs_to :movie_category
  has_many :seat_categories, dependent: :destroy
  has_many :showtimes, dependent: :destroy
  has_many :theaters, through: :showtimes
  has_many :ratings, as: :rateable, dependent: :destroy
  has_one_attached :avatar

  validates :title, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[id title description movie_category.name created_at updated_at ratings.value showtimes.theater.name showtimes.theater.location showtimes.datetime seat_categories.name]
  end

  def self.ransackable_associations(auth_object = nil)
    ["movie_category", "ratings", "showtimes", "seat_categories"]
  end
end
