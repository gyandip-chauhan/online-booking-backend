class EventsRawsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @events_raws = EventsRaw.filter(params).limit(params[:per_page] || 10)
    render json: EventsRawSerializer.new(@events_raws), status: 200
  end

  def filter_options
    option_types = params[:option_types].split(',') if params[:option_types].present?
    options = {}

    if option_types.nil? || option_types.empty?
      render json: { error: "No option types provided" }, status: 400
      return
    end

    option_types.each do |option_type|
      if option_type == 'surface'
        options[:surface_options] = EventsRaw.unique_values_for_surface_event
      elsif EventsRaw.attribute_names.include?(option_type)
        options["#{option_type}_options".to_sym] = EventsRaw.unique_values_for(option_type)
      else
        render json: { error: "Invalid option type: #{option_type}" }, status: 400
        return
      end
    end

    render json: options, status: 200
  end
end
