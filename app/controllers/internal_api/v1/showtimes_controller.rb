# app/controllers/showtimes_controller.rb
module InternalApi::V1
  class ShowtimesController < ApplicationController
    skip_before_action :authenticate_user!, :authenticate_user_using_x_auth_token, only: [:index, :show]

    def index
      @categories = MovieCategory.includes(movies: :showtimes).joins(:movies).where(params[:movie_id].present? ? { movies: { id: params[:movie_id] } } : {}).distinct
      render json: { categories: MovieCategorySerializer.new(@categories).as_json }
    end  
  
    def show
      @showtime = Showtime.find(params[:id])
      @theater = Theater.find(params[:theater_id])
      @screen = Screen.find(params[:screen_id])
      @movie = Movie.find(params[:movie_id])
      @seat_categories = SeatCategory.where(screen: @screen, theater: @theater, movie: @movie).order("price DESC")
      @showtime_seats_group_by_sc = ShowtimeSeat.where(showtime: @showtime, seat_category: @seat_categories).group_by(&:seat_category_id).transform_values{|val| val.first}
      
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
