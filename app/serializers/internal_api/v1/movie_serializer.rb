module InternalApi::V1
  class MovieSerializer < ApplicationSerializer
    attributes :id, :title, :movie_category_id, :description, :created_at, :updated_at
    
    # attribute :movie_category do |object|
    #   MovieCategorySerializer.new(object.movie_category)
    # end
    attribute :showtimes do |object, params|
      ShowtimeSerializer.new(object.showtimes) if !params[:disable_showtimes]
    end
    # attribute :theaters do |object|
    #   TheaterSerializer.new(object.theaters)
    # end
    # attribute :seat_categories do |object|
    #   SeatCategorySerializer.new(object.seat_categories)
    # end
    attribute :avatar_url do |object|
      if object.avatar.attached?
        'http://192.168.31.211:3000' + Rails.application.routes.url_helpers.rails_blob_path(object.avatar, only_path: true)
      else
        nil
      end
    end
  end
end
