class Showtime < ApplicationRecord
  belongs_to :movie
  belongs_to :theater
  belongs_to :screen
  has_many :bookings, dependent: :destroy
  has_many :showtime_seats, dependent: :destroy

  validates :time, presence: true
  validate :time_cannot_be_in_the_past
  validate :time_difference_between_showtimes

  after_create :create_showtime_seats

  def self.ransackable_attributes(auth_object = nil)
    %w[id movie.title theater.name theater.location screen.name time created_at updated_at bookings.seats]
  end

  def self.ransackable_associations(auth_object = nil)
    ["bookings", "movie", "theater", "screen"]
  end

  def update_available_seats(selected_seats, booking)
    total_price = 0.0

    # Preload seat categories and showtime seats
    seat_categories = SeatCategory.includes(:showtime_seats).where(name: selected_seats.keys)
    showtime_seats = ShowtimeSeat.includes(:seat_category).where(seat_category: seat_categories)

    ActiveRecord::Base.transaction do
      begin
        selected_seats.each do |seat_category_name, seats|
          seat_category = seat_categories.find { |sc| sc.name == seat_category_name }
          showtime_seat = showtime_seats.find { |ss| ss.seat_category == seat_category }

          next unless seat_category && showtime_seat

          selected_seat_numbers = seats.map { |seat| seat['seat'] }
          available_seats = (showtime_seat.seats.split(",") - selected_seat_numbers).join(",")

          unless showtime_seat.update(seats: available_seats)
            raise ActiveRecord::Rollback, "Error updating showtime seat: #{showtime_seat.errors.full_messages.join(', ')}"
          end

          selected_seats_price = (selected_seat_numbers.size * seat_category.price.to_f).round(2)
          total_price += selected_seats_price

          unless booking.booked_seats.create!(seat_category: seat_category, seats: selected_seat_numbers.join(","), price: selected_seats_price)
            raise ActiveRecord::Rollback, "Error creating booked seats: #{booking.errors.full_messages.join(', ')}"
          end
        end

        # Update booking total price
        unless booking.update(total_price: total_price.round(2))
          raise ActiveRecord::Rollback, "Error updating booking: #{booking.errors.full_messages.join(', ')}"
        end

        puts "Updated available seats and booked seats. Total price: #{total_price.round(2)}"
      rescue ActiveRecord::Rollback => e
        puts "Transaction rolled back: #{e.message}"
        # You can log the error or handle it in a way that fits your application
        raise e
      end
    end
  end


  private

  def create_showtime_seats
    SeatCategory.where(theater: theater, screen: screen).each{|sc| self.showtime_seats.create!(seat_category_id: sc.id, seats: sc.seats) }
  end

  def time_cannot_be_in_the_past
    errors.add(:time, "can't be in the past") if time.present? && time < DateTime.now
  end

  def time_difference_between_showtimes
    return unless time.present?

    latest_showtime = Showtime.where(theater: theater, screen: screen)
                              .where.not(id: id)
                              .order(time: :desc)
                              .first

    if latest_showtime.present? && time <= latest_showtime.time + 3.hours
      errors.add(:time, "must be at least 3 hours later than the latest showtime for the same theater and screen")
    end
  end
end
