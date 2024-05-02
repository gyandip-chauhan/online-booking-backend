module InternalApi::V1
  class MovieCastAndCrewSerializer < ApplicationSerializer
    attributes :id, :name, :movie_id, :role, :kind, :created_at, :updated_at
    
    attribute :image_url do |object|
      if object.image.attached?
        Rails.application.routes.url_helpers.url_for(object.image)
      else
        nil
      end
    end
  end
end
