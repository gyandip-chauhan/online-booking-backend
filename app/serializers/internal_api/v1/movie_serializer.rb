module InternalApi::V1
  class MovieSerializer < ApplicationSerializer
    attributes :id, :title, :movie_category_id, :description, :trailer_url, :created_at, :updated_at
    
    attribute :casts do |object, params|
      MovieCastAndCrewSerializer.new(object.casts) if !params[:disable_casts]
    end
    attribute :crews do |object, params|
      MovieCastAndCrewSerializer.new(object.crews) if !params[:disable_crews]
    end
    attribute :showtimes do |object, params|
      ShowtimeSerializer.new(object.showtimes) if !params[:disable_showtimes]
    end

    attribute :avatar_url do |object|
      if object.avatar.attached?
        Rails.application.routes.url_helpers.url_for(object.avatar)
      else
        nil
      end
    end
  end
end
