class EventsRaw < ApplicationRecord
  FILTER_FIELDS = [
    :section, :stage, :event_order, :event, :event_date,
    :count_column, :project_id, :project_name, :project_status,
    :build_card_id, :start_month, :build_card_type, :region,
    :period_type, :month_year
  ].freeze

  SEARCH_FIELDS = [:stage, :event_order, :project_id, :project_name, :build_card_id, :build_card_type].freeze

  def self.filter(params)
    filter_data = all
    FILTER_FIELDS.each do |field|
      filter_data = filter_field(filter_data, field, params[field]) if params[field].present?
    end
    if params[:from_date].present? && params[:to_date].present?
      filter_data = filter_by_event_date_range(filter_data, params[:from_date], params[:to_date])
    end
    filter_data = filter_by_search_term(filter_data, params[:search_term]) if params[:search_term].present?
    filter_data = sort_data(filter_data, params[:sort_by], params[:sort_order]) if params[:sort_by].present?
    filter_data
  end

  def self.unique_values_for(attribute)
    distinct.pluck(attribute).sort_by(&:to_s)
  end

  def self.unique_values_for_surface_event
    distinct.pluck(:event).map { |e| e.split(' - ').first }.uniq.sort_by(&:to_s)
  end

  private

  def self.filter_field(data, field, value)
    data.where("#{field} IN (?)", value.split(","))
  end

  def self.filter_by_event_date_range(data, from_date, to_date)
    data.where("event_date::date BETWEEN ? AND ?", from_date, to_date)
  end

  def self.filter_by_search_term(data, search_term)
    conditions = SEARCH_FIELDS.map { |field| "#{field}::text ILIKE :search" }.join(" OR ")
    data.where(conditions, search: "%#{search_term}%")
  end

  def self.sort_data(data, sort_by, sort_order)
    return data unless EventsRaw.attribute_names.include?(sort_by)
    sort_order = sort_order&.downcase == 'desc' ? 'DESC' : 'ASC'
    data.order("#{sort_by} #{sort_order}")
  end
end
