class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :rateable, polymorphic: true

  validates :value, inclusion: { in: 1..5 }

  def self.ransackable_attributes(auth_object = nil)
    %w[id rateable_id rateable_type user_id value created_at updated_at user.email user.username]
  end
end
