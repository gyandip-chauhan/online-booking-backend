module InternalApi::V1
  class EventsRawSerializer < ApplicationSerializer
    attributes :id,  :section, :stage, :event_order, :event, :event_date, :count_column, :project_id, :project_name, :project_status, :build_card_id, :start_month, :build_card_type, :region, :period_type, :month_year, :created_at, :updated_at 
  end
end
