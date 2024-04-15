class BookingTransaction < ApplicationRecord
  belongs_to :booking
  belongs_to :user

  enum :status, [ :pending, :verified ]

  def self.ransackable_attributes(auth_object = nil)
    ["amount", "booking_id", "created_at", "id", "payment_provider", "status", "stripe_payment_id", "updated_at", "user_id"]
  end
end
