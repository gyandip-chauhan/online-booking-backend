class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  recommends :movies, :theaters
  has_many :ratings
  has_many :bookings

  def my_bookings
    bookings.where(is_cancelled: false)
  end

  def cancel_bookings
    bookings.where(is_cancelled: true)
  end
end
