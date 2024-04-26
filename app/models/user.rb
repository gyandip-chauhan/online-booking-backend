class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  recommends :movies, :theaters
  has_many :ratings, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :booking_transactions, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  before_create :set_token

  def my_bookings
    bookings.where(is_cancelled: false)
  end

  def cancel_bookings
    bookings.where(is_cancelled: true)
  end

  def self.create_stripe_customers(account)
    stripe_customer = Stripe::Customer.create({ email: account.email })
    account.stripe_id = stripe_customer.id
    account.save
  end

  def self.ransackable_attributes(auth_object = nil)
    ["balance", "created_at", "email", "id", "referral_code", "referred_reward", "referrer_reward", "remember_created_at", "reset_password_sent_at", "reset_password_token", "stripe_id", "token", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["booking_transactions", "bookings", "ratings"]
  end

  private

  def set_token
    self.token = SecureRandom.base58(50)
  end
end
