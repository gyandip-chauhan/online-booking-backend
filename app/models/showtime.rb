class Showtime < ApplicationRecord
  belongs_to :movie
  belongs_to :theater
  belongs_to :screen
  has_many :bookings, dependent: :destroy
  has_many :showtime_seats, dependent: :destroy
  has_many :showtimes, through: :movie

  validates :time, presence: true
  validate :time_cannot_be_in_the_past
  validate :time_difference_between_showtimes

  after_create :create_showtime_seats

  after_update :check_showtime_seats

  def self.ransackable_attributes(auth_object = nil)
    %w[id movie.title theater.name theater.location screen.name time created_at updated_at bookings.seats]
  end

  def self.ransackable_associations(auth_object = nil)
    ["bookings", "movie", "theater", "screen"]
  end

  def update_available_seats(selected_seats, booking)
    total_price = 0.0
  
    # Preload seat categories and showtime seats
    seat_categories = SeatCategory.includes(:showtime_seats).where(name: selected_seats.keys, movie: movie, screen: screen, theater: theater)
    showtime_seats = self.showtime_seats.includes(:seat_category).where(seat_category: seat_categories)
  
    ActiveRecord::Base.transaction do
      selected_seats.each do |seat_category_name, seats|
        seat_category = seat_categories.find { |sc| sc.name == seat_category_name }
        showtime_seat = showtime_seats.find { |ss| ss.seat_category == seat_category }
  
        next unless seat_category && showtime_seat
  
        selected_seat_numbers = seats.map { |seat| seat['seat'] }
  
        selected_seats_price = (selected_seat_numbers.size * seat_category.price.to_f).round(2)
        total_price += selected_seats_price
  
        booked_seat = booking.booked_seats.new(seat_category: seat_category, seats: selected_seat_numbers.join(","), price: selected_seats_price)
  
        unless booked_seat.save
          booked_seat.errors.full_messages.each do |error_message|
            booking.errors.add(:base, error_message)
          end
          raise ActiveRecord::RecordInvalid, booking
        end
  
        available_seats = (showtime_seat.seats.split(",") - selected_seat_numbers).join(",")
        unless showtime_seat.update(seats: available_seats)
          showtime_seat.errors.full_messages.each do |error_message|
            booking.errors.add(:base, error_message)
          end
          raise ActiveRecord::RecordInvalid, booking
        end
      end
  
      unless booking.update(total_price: total_price.round(2))
        raise ActiveRecord::RecordInvalid, booking
      end
      
      puts "Updated available seats and booked seats. Total price: #{total_price.round(2)}"
    end
  end 

  private

  def create_showtime_seats
    begin
      unless SeatCategory.where(theater: theater, screen: screen, movie: movie).any?
        check_showtime_seats
      else
        SeatCategory.where(theater: theater, screen: screen, movie: movie).each{|sc| self.showtime_seats.create!(seat_category_id: sc.id, seats: sc.seats) }
      end
    rescue StandardError => e
      puts "Error in create_showtime_seats: #{e.message}"
    end
  end

  def check_showtime_seats
    begin
      unless SeatCategory.where(theater: theater, screen: screen, movie: movie).any?
        unless (seat_category = SeatCategory.find_by(name: 'Golden', price: 250, theater: theater, screen: screen, movie: movie)).present?
          seat_category = SeatCategory.create!(name: 'Golden', price: 250, theater: theater, screen: screen, movie: movie, start_num_of_seat: 1, end_num_of_seat: 10, seats: (1..10).to_a.join(','))
        end
        self.showtime_seats.create!(seat_category_id: seat_category.id, seats: seat_category.seats)
      end
    rescue StandardError => e
      puts "Error in check_showtime_seats: #{e.message}"
    end
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
