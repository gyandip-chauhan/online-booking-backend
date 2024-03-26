class OdbcConnection
  IMPORT_BATCH_SIZE = Rails.env.test? ? 5 : 1000

  def initialize
    odbc_url = build_odbc_url
    @connection = DBI.connect("DBI:ODBC:#{odbc_url}", '', '')
    @odbc_last_index = fetch_odbc_last_index
  end

  def import_data
    if allow_to_import_data
      import_data_in_batches(@connection)
    else
      Rails.logger.info "No new records to import."
    end
  end

  def filter_data(params)
    sql_query = "SELECT * FROM gold_staging.project_helios.events_raw"
    conditions = []
    values = []

    FILTER_FIELDS.each do |field|
      if params[field].present?
        conditions << "#{field} IN (?)"
        values << params[field]
      end
    end

    if params[:from_date].present? && params[:to_date].present?
      conditions << "event_date BETWEEN ? AND ?"
      values << params[:from_date]
      values << params[:to_date]
    end

    if params[:surface].present?
      conditions << "substring(event from '^[^-]+') ILIKE ?"
      values << "%#{params[:surface]}%"
    end

    if params[:search_term].present?
      search_conditions = SEARCH_FIELDS.map { |field| "#{field} ILIKE ?" }.join(" OR ")
      conditions << "(#{search_conditions})"
      values += [params[:search_term]] * SEARCH_FIELDS.length
    end

    if conditions.present?
      sql_query += " AND #{conditions.join(' AND ')}"
    end

    sql_query += " ORDER BY #{params[:sort_by] || 'event_date'} #{params[:sort_order] || 'ASC'}"
    sql_query += " LIMIT #{params[:per_page] || 10} OFFSET #{params[:offset] || 0}"

    result_set = @connection.execute(sql_query, *values.flatten)
    events_raws = result_set.map do |row|
      {
        section: row['section'],
        stage: row['stage'],
        event_order: row['event_order'],
        event: row['event'],
        event_date: row['event_date'],
        count_column: row['count_column'],
        project_id: row['project_id'],
        project_name: row['project_name'],
        project_status: row['project_status'],
        build_card_id: row['build_card_id'],
        start_month: row['start_month'],
        build_card_type: row['build_card_type'],
        region: row['region'],
        period_type: row['period_type'],
        month_year: row['month_year']
      }
    end

    result_set.finish
    @connection.disconnect

    events_raws
  end

  def filter_options(option_types)
    options = {}
    option_types.each do |option_type|
      if option_type == 'surface'
        sql_query = "SELECT DISTINCT split_part(event, ' - ', 1) FROM gold_staging.project_helios.events_raw ORDER BY split_part(event, ' - ', 1) ASC"
      elsif EventsRaw.attribute_names.include?(option_type)
        sql_query = "SELECT DISTINCT #{option_type} FROM gold_staging.project_helios.events_raw ORDER BY #{option_type} ASC"
      end
      result_set = @connection.execute(sql_query)
      options["#{option_type}_options".to_sym] = []
      while row = result_set.fetch do
        options["#{option_type}_options".to_sym] << row[0]
      end
      result_set.finish
    end
    @connection.disconnect
    options
  end

  private

  def build_odbc_url
    driver_path = ENV['DRIVER_PATH']
    db_host = ENV['DATABRICKS_SERVER_HOSTNAME']
    http_path = ENV['DATABRICKS_HTTP_PATH']
    service_principal_id = ENV['DATABRICKS_CLIENT_ID']
    service_principal_secret = ENV['DATABRICKS_CLIENT_SECRET']

    "Port=443;DRIVER=#{driver_path};Host=#{db_host};HTTPPath=#{http_path};SSL=1;ThriftTransport=2;AuthMech=11;Auth_Flow=1;Auth_Client_Id=#{service_principal_id};Auth_Client_Secret=#{service_principal_secret};Auth_Scope=all-apis"
  end

  def fetch_local_last_index
    result = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM events_raws")
    total_records = result[0]['count'].to_i
    total_records
  end

  def fetch_odbc_last_index
    result = @connection.execute("SELECT COUNT(*) AS record_count FROM gold_staging.project_helios.events_raw")
    count_result = result.fetch
    total_records = count_result['record_count'].to_i
    total_records
  end

  def allow_to_import_data
    last_local_index = fetch_local_last_index
    last_local_index < @odbc_last_index
  end

  def import_data_in_batches(connection)
    offset = fetch_local_last_index
    total_imported = 0

    loop do
      result_set = connection.execute("
                                        SELECT * FROM (
                                          SELECT *, ROW_NUMBER() OVER (ORDER BY event_date) AS row_num
                                          FROM gold_staging.project_helios.events_raw
                                        ) AS sub
                                        WHERE row_num > #{offset}
                                        LIMIT #{IMPORT_BATCH_SIZE}
                                      ")



      events_raw_data = []
      successful_imports = 0

      while row = result_set.fetch do
        events_raw_data << {
          section: row['section'],
          stage: row['stage'],
          event_order: row['event_order'],
          event: row['event'],
          event_date: row['event_date'],
          count_column: row['count_column'],
          project_id: row['project_id'],
          project_name: row['project_name'],
          project_status: row['project_status'],
          build_card_id: row['build_card_id'],
          start_month: row['start_month'],
          build_card_type: row['build_card_type'],
          region: row['region'],
          period_type: row['period_type'],
          month_year: row['month_year']
        }
        successful_imports += 1
      end

      result_set.finish

      imported = EventsRaw.import(events_raw_data)
      total_imported += imported.ids.size

      offset += IMPORT_BATCH_SIZE

      Rails.logger.info "Batch Import: #{successful_imports} records imported successfully at #{DateTime.current.strftime('%d-%m-%Y %H:%M:%S')}."
      break if (Rails.env.test? ? (successful_imports == IMPORT_BATCH_SIZE) : (successful_imports < (IMPORT_BATCH_SIZE || !allow_to_import_data)))
    end
    Rails.logger.info "Total Import: #{total_imported} records imported successfully in total at #{DateTime.current.strftime('%d-%m-%Y %H:%M:%S')}."
    @connection.disconnect
  end
end
