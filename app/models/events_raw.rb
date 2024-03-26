module BxBlockEventsRaw
  class EventsRaw < ApplicationRecord
    self.table_name = :events_raws
    self.primary_key = nil

    default_scope { order(event_date: :asc) }
    
    FILTER_FIELDS = [
      :section, :stage, :event, :region
    ].freeze

    SEARCH_FIELDS = [:stage, :event_order, :project_id, :project_name, :build_card_id, :build_card_type].freeze

    def self.filter(params)
      params[:from_date] ||= 1.months.ago.beginning_of_month.to_date
      params[:to_date] ||= Date.today
      
      filter_data = all
      FILTER_FIELDS.each do |field|
        filter_data = filter_field(filter_data, field, params[field]) if params[field].present?
      end
      filter_data = filter_by_event_date_range(filter_data, params[:from_date], params[:to_date]) if params[:from_date].present? && params[:to_date].present?
      filter_data = filter_by_surface(filter_data, params[:surface]) if params[:surface].present?
      filter_data = filter_by_search_term(filter_data, params[:search_term]) if params[:search_term].present?
      filter_data = sort_data(filter_data, params[:sort_by], params[:sort_order]) if params[:sort_by].present?
      filter_data
    end

    def self.unique_values_for(attribute)
      select(attribute).pluck(attribute).uniq.sort_by(&:to_s)
    end

    def self.unique_values_for_surface_event
      select(:event).pluck(:event).map { |e| e.split(' - ').first }.uniq.sort_by(&:to_s)
    end

    def self.generate_sankey_data(raw_data)
      nodes = []
      links = []

      # generate_nodes_and_links(raw_data.select(:event, :stage, :section, :build_card_type), nodes, links)
      generate_nodes_and_links(raw_data.select(:event, :stage, :build_card_id), nodes, links)

      { nodes: nodes, links: links }
    end

    private

    def self.filter_field(data, field, value)
      data.where("#{field} IN (?)", value.split(","))
    end

    def self.filter_by_event_date_range(data, from_date, to_date)
      data.where("event_date::date BETWEEN ? AND ?", from_date, to_date)
    end

    def self.filter_by_surface(data, surface)
      data.where("substring(event from '^[^-]+') ILIKE ?", "#{surface}%")
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

    def self.generate_nodes_and_links(raw_data, nodes, links)
      events_data = {}
      # stages_data = {}
      nodes_to_add = []
      links_to_add = []
      common_color = "#bdc8d4"

      # events = ["Facebook Ads","Linkedin Ads","Stackadapt Ads","Youtube Ads","Google Search Ads","Other Ads displayed","Sales outreach","Organic and direct traffic","Partnership","In Platform form submitted (ads)","Landing page visit","Web page visit"]

      events = raw_data.pluck(:event).uniq
      # stages = raw_data.pluck(:stage).uniq
      # sections = raw_data.pluck(:section).uniq
      # build_card_types = raw_data.pluck(:build_card_type).uniq

      # stages.each do |stage|
      #   stages_data[stage] = raw_data.where(stage: stage)
      #   nodes_to_add << { name: stage, color: generate_color, column: 0}
      # end

      # events.each_with_index do |event, index|
      #   nodes_to_add << { name: event, color: common_color, column: index+1}
      # end

      # stages_data.each do |stage, s_data|
      #   starting_point_index = nodes_to_add.find_index { |n| n[:name] == stage }

      #   stage_events = s_data.pluck(:event).uniq

      #   if stage_events.count == 1
      #     target_index = nodes_to_add.find_index { |n| n[:name] == stage_events.first }
      #     links_to_add << { source: starting_point_index, target: target_index, value: s_data.pluck(:build_card_id).uniq.count }  unless links_to_add.any? { |n| n[:source] == starting_point_index && n[:target] == target_index }
      #   end

      #   stage_events.each_cons(2).each_with_index do |(event1, event2), index|
      #     source_index = nodes_to_add.find_index { |n| n[:name] == event1 }
      #     target_index = nodes_to_add.find_index { |n| n[:name] == event2 }
      #     if index == 0
      #       target_index = source_index
      #       source_index = starting_point_index
      #       bc_ids_count = s_data.where(event: event1).pluck(:build_card_id).uniq.count
      #     else
      #       bc_ids_count = s_data.where(event: event2).pluck(:build_card_id).uniq.count
      #     end
      #     links_to_add << { source: source_index, target: target_index, value: bc_ids_count } unless links_to_add.any? { |n| n[:source] == source_index && n[:target] == target_index }
      #   end
      # end

      events.each_with_index do |event, index|
        events_data[event] = raw_data.where(event: event).size #.pluck(:build_card_id).uniq.count
        nodes_to_add << { name: event, color: index == 0 ? generate_color : common_color, column: index}
      end

      events.each_cons(2).each_with_index do |(event1, event2), index|
        source_index = nodes_to_add.find_index { |n| n[:name] == event1 }
        target_index = nodes_to_add.find_index { |n| n[:name] == event2 }
        links_to_add << { source: source_index, target: target_index, value: events_data[event2] } unless links_to_add.any? { |n| n[:source] == source_index && n[:target] == target_index }
      end

      # [stages, sections, build_card_types].flatten.each do |node_name|
      #   nodes_to_add << { name: node_name, color:common_color, column: 1}
      # end

      # events.product(stages, sections, build_card_types).each do |event, stage, section, build_card_type|
      #   next unless events_data[event]

      #   stage_data = events_data[event].where(stage: stage)
      #   next if (stage_data_size = stage_data.size) == 0
      #   event_index = nodes_to_add.find_index { |n| n[:name] == event }
      #   stage_index = nodes_to_add.find_index { |n| n[:name] == stage }
      #   links_to_add << { source: event_index, target: stage_index, value: stage_data_size } unless links_to_add.any? { |n| n[:source] == event_index && n[:target] == stage_index }
        
      #   section_data = stage_data.where(section: section)
      #   next if (section_data_size = section_data.size) == 0
      #   section_index = nodes_to_add.find_index { |n| n[:name] == section }
      #   links_to_add << { source: stage_index, target: section_index, value: section_data_size } unless links_to_add.any? { |n| n[:source] == stage_index && n[:target] == section_index }
        
      #   build_card_type_data = section_data.where(build_card_type: build_card_type)
      #   next if (build_card_type_data_size = build_card_type_data.size) == 0
      #   build_card_type_index = nodes_to_add.find_index { |n| n[:name] == build_card_type }
      #   links_to_add << { source: section_index, target: build_card_type_index, value: build_card_type_data_size } unless links_to_add.any? { |n| n[:source] == section_index && n[:target] == build_card_type_index }
      # end

      nodes.concat(nodes_to_add)
      links.concat(links_to_add)
    end

    def self.generate_color
      # colors = ["#8c31ff", "#ff8c52", "#2156ef", "#63d2ef", "#fff352", "#73e7ad", "#ff67c6", "#ff3531", "#bdc8d4"]
      "#" + SecureRandom.hex(3)
    end
  end
end
