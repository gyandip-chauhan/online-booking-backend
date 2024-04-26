class BookingNotifier < ApplicationNotifier
  deliver_by :email do |config, options|
    config.mailer = "UserMailer"
    config.method = "new_booking"
  end

  notification_methods do
    def message
      @booking = record
      @movie = @booking.movie
      @booking_details = {
        'Movie' => @movie.title,
        'Theater' => @booking.showtime.theater.name,
        'Location' => @booking.showtime.theater.location,
        'Date & Time' => @booking.showtime.time.strftime('%B %d, %Y %I:%M %p'),
        'Seats' => @booking.booked_seats.group_by(&:seat_category).map { |sc, b_seats| "#{sc.name}: #{b_seats.pluck(:seats).join(',')}" }.flatten.join(","),
        'Total Price' => @booking.total_price
      }
      "Movie(#{@booking_details['Movie']}) Ticket Confirmed at #{@booking_details['Theater']}, #{@booking_details['Location']} on #{@booking_details['Date & Time']}"
    end
  end
end
