class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :showtime
  has_one :movie, through: :showtime
  has_one :theater, through: :showtime
  has_many :booked_seats, dependent: :destroy
  has_many :booking_transactions, dependent: :destroy
  has_noticed_notifications model_name: 'Noticed::Event'
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: 'Noticed::Event'

  before_destroy :update_showtime_seats

  enum :status, [ :payment_pending, :confirmed ]

  def self.ransackable_attributes(auth_object = nil)
    super & %w[id total_price is_cancelled stripe_payment_method_id source status movie.title theater.name theater.location created_at updated_at user.email user.username seats]
  end

  def self.ransackable_associations(auth_object = nil)
    ["booked_seats", "booking_transactions", "showtime", "user", "movie", "theater"]
  end

  def cancel_booking
    ActiveRecord::Base.transaction do
      begin
        booked_seats.each do |booked_seat|
          seat_category = booked_seat.seat_category
          showtime_seat = showtime.showtime_seats.find_by(seat_category: seat_category)

          next unless showtime_seat

          available_seats = (showtime_seat.seats.split(",") + booked_seat.seats.split(",")).uniq.sort.join(",")
          
          unless showtime_seat.update(seats: available_seats)
            raise ActiveRecord::RecordInvalid, showtime_seat
          end
        end
        
        unless self.update(is_cancelled: true, total_price: 0.0)
          raise ActiveRecord::RecordInvalid, self
        end

        puts "Booking canceled successfully."
      rescue ActiveRecord::RecordInvalid => e
        puts "Error updating seats or cancelling booking: #{e.record.errors.full_messages.join(', ')}"
        raise e
      rescue ActiveRecord::Rollback => e
        puts "Transaction rolled back: #{e.message}"
        raise e
      end
    end
  end

  private

  def update_showtime_seats
    ActiveRecord::Base.transaction do
      begin
        booked_seats.each do |booked_seat|
          seat_category = booked_seat.seat_category
          showtime_seat = showtime.showtime_seats.find_by(seat_category: seat_category)

          next unless showtime_seat

          available_seats = (showtime_seat.seats.split(",") + booked_seat.seats.split(",")).uniq.sort.join(",")
          unless showtime_seat.update(seats: available_seats)
            raise ActiveRecord::RecordInvalid, showtime_seat
          end
        end

        puts "Booking deleted successfully."
      rescue ActiveRecord::RecordInvalid => e
        puts "Error updating seats or deleting booking: #{e.record.errors.full_messages.join(', ')}"
        raise e
      rescue ActiveRecord::Rollback => e
        puts "Transaction rolled back: #{e.message}"
        raise e
      end
    end
  end
end
