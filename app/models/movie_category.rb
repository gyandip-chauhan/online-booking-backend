class MovieCategory < ApplicationRecord
  has_many :movies, dependent: :destroy
  validates :name, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[id name created_at updated_at movies.name]
  end

  def self.ransackable_associations(auth_object = nil)
    ["movies"]
  end
end
