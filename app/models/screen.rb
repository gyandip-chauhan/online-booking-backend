class Screen < ApplicationRecord
  has_many :showtimes, dependent: :destroy
  has_many :seat_categories, dependent: :destroy
  validates :name, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[id name showtimes.time seat_categories.theater.name seat_categories.seats seat_categories.price created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    ["showtimes", "seat_categories"]
  end
end
