# app/controllers/showtimes_controller.rb
module InternalApi::V1
  class ShowtimesController < ApplicationController
    skip_before_action :authenticate_user!, :authenticate_user_using_x_auth_token, only: [:index, :show]

    def index
      movie = params[:movie_id] ? Movie.find(params[:movie_id]) : nil
      
      # @showtimes = Showtime.where('time >= ?', DateTime.current).where(params[:movie_id].present? ? { movie_id: params[:movie_id] } : {}).order(:time)
      @showtimes = Showtime.filter(params)
      
      # Calculate price ranges
      seat_categories = SeatCategory.where(params[:movie_id].present? ? { movie_id: params[:movie_id] } : {})
      prices = seat_categories.pluck(:price).uniq
      min_price = prices.min
      max_price = prices.max
      step = 50
      price_ranges = []
      if min_price != max_price
        (min_price..max_price).step(step) do |start_price|
          end_price = start_price + step
          end_price = max_price if end_price > max_price
          price_ranges << {value: "#{start_price}-#{end_price}", label: "#{start_price}-#{end_price}"} unless start_price == end_price
        end
      else
        price_ranges << {value: "0-#{max_price}", label: "0-#{max_price}"}
      end

      # Render JSON response
      render json: {
        showtimes: ShowtimeSerializer.new(@showtimes).as_json,
        movie: movie ? MovieSerializer.new(movie).as_json : nil,
        price_ranges: price_ranges,
        theaters: TheaterSerializer.new(Theater.all).as_json,
        screens: ScreenSerializer.new(Screen.all).as_json
      }
    end
  
    def show
      @showtime = Showtime.find(params[:id])
      @theater = Theater.find(params[:theater_id])
      @screen = Screen.find(params[:screen_id])
      @movie = Movie.find(params[:movie_id])
      @showtime_seats = @showtime.showtime_seats
      seat_cat_ids = @showtime_seats.pluck(:seat_category_id).uniq
      @seat_categories = SeatCategory.where(id: seat_cat_ids).order("price DESC")
      @showtime_seats_group_by_sc = @showtime_seats.group_by(&:seat_category_id).transform_values{|val| val.first}
      
      response_data = {
        showtime: @showtime,
        theater: @theater,
        screen: @screen,
        movie: @movie,
        seat_categories: @seat_categories,
        showtime_seats_group_by_sc: @showtime_seats_group_by_sc,
      }
  
      render json: response_data
    end
  
    def select_seat
      selected_seats = params[:selected_seats] || {}
  
      total_price = calculate_total_price(selected_seats.values.flatten)
  
      render json: { total_price: total_price }
    end
  
    def book_now
      showtime = Showtime.find(params[:id])
      selected_seats = params[:selected_seats] || {}
  
      booking = current_user.bookings.create(showtime: showtime)
  
      begin
        showtime.update_available_seats(selected_seats, booking)
        response_data = {
          success: true,
          booking_id: booking.id,
          redirect_to: invoice_booking_path(booking, showtime_id: showtime.id)
        }
        render json: response_data
      rescue ActiveRecord::RecordInvalid => e
        render json: { success: false, error: e.record.errors.full_messages.join(', ') }
      end
    end
  
    private
  
    def calculate_total_price(selected_seats)
      total_price = selected_seats.map { |item| item["price"].to_i }.sum
    end
  end
end
