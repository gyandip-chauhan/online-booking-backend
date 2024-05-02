class Movie < ApplicationRecord
  belongs_to :movie_category
  has_many :seat_categories, dependent: :destroy
  has_many :showtimes, dependent: :destroy
  has_many :movie_cast_and_crews, dependent: :destroy
  has_many :theaters, through: :showtimes
  has_many :ratings, as: :rateable, dependent: :destroy
  has_one_attached :avatar
  accepts_nested_attributes_for :movie_cast_and_crews, allow_destroy: true

  validates :title, presence: true

  def casts
    movie_cast_and_crews.where(kind: 'cast')
  end

  def crews
    movie_cast_and_crews.where(kind: 'crew')
  end
  
  def self.ransackable_attributes(auth_object = nil)
    %w[id title description movie_category.name trailer_url created_at updated_at ratings.value showtimes.theater.name showtimes.theater.location showtimes.datetime seat_categories.name]
  end

  def self.ransackable_associations(auth_object = nil)
    ["movie_category", "ratings", "showtimes", "seat_categories", "movie_cast_and_crews"]
  end
end
