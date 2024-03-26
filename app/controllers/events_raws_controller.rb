class EventsRawsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @events_raws = EventsRaw.filter(params).limit(params[:per_page] || 10)
    @chart_data = generate_chart_data(@events_raws, params[:chart_type] || 'sankey')
    render json: @chart_data, status: 200
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

  def filter_data_via_odbc
    begin
      @events_raws = OdbcConnection.new.filter_data(params)
      render json: @events_raws, status: 200
    rescue => e
      render json: { error: e.message }, status: 400
      return
    end
  end

  def filter_options_via_odbc
    option_types = params[:option_types].split(',') if params[:option_types].present?

    if option_types.nil? || option_types.empty?
      render json: { error: "No option types provided" }, status: 400
      return
    end

    if (invalid_option_types = (option_types - (EventsRaw.attribute_names + ["surface"]))).present?
      render json: { error: "Invalid option types: #{invalid_option_types.join(', ')}" }, status: 400
      return
    end

    begin
      options = OdbcConnection.new.filter_options(option_types)
      render json: options, status: 200
    rescue => e
      render json: { error: e.message }, status: 400
      return
    end
  end

  private

  def generate_chart_data(events_raws, chart_type)
    case chart_type
    when 'sankey'
      EventsRaw.generate_sankey_data(events_raws)
    else
      render json: { error: "Invalid chart type: #{chart_type}" }, status: 400
      return
    end
  end
end
