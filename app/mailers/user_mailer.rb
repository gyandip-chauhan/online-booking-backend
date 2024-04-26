class UserMailer < Devise::Mailer
  default from: "<#{ENV['DEFAULT_FROM_EMAIL']}>"
  
  def reset_password_instructions(record, token, opts={})
    super
  end

  def confirmation_instructions(record, token, opts={})
    super
  end

  def new_booking
    @resource = params[:recipient]
    @booking = params[:record]
    @movie = @booking.movie
    @booking_details = {
      'Customer Email' => @resource.email,
      'Movie' => @movie.title,
      'Theater' => @booking.showtime.theater.name,
      'Location' => @booking.showtime.theater.location,
      'Date & Time' => @booking.showtime.time.strftime('%B %d, %Y %I:%M %p'),
      'Seats' => @booking.booked_seats.group_by(&:seat_category).map { |sc, b_seats| "#{sc.name}: #{b_seats.pluck(:seats).join(',')}" }.flatten.join(","),
      'Total Price' => @booking.total_price
    }

    mail(to: @resource.email, subject: "BookMyShow Movie Ticket Booking Confirmation")
  end

  # private

  # def add_inline_attachments!
  #   attachments.inline['your-logo.png'] = File.read(Rails.root.join('app/assets/images/your-logo.png'))
  # end
end
 