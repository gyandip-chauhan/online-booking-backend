require 'dbi'
require 'activerecord-import/base'
ActiveRecord::Import.require_adapter('postgresql') 

class OdbcConnection
  BATCH_SIZE = Rails.env.test? ? 5 : 100000

  def initialize
    establish_connection
  end

  def import_data
    establish_connection unless @connection
    import_data_in_batches(@connection)
  end

  private

  def establish_connection
    odbc_url = build_odbc_url
    @connection = DBI.connect("DBI:ODBC:#{odbc_url}", '', '')
  end

  def build_odbc_url
    driver_path = ENV['DRIVER_PATH']
    db_host = ENV['DATABRICKS_SERVER_HOSTNAME']
    http_path = ENV['DATABRICKS_HTTP_PATH']
    service_principal_id = ENV['DATABRICKS_CLIENT_ID']
    service_principal_secret = ENV['DATABRICKS_CLIENT_SECRET']

    "Port=443;DRIVER=#{driver_path};Host=#{db_host};HTTPPath=#{http_path};SSL=1;ThriftTransport=2;AuthMech=11;Auth_Flow=1;Auth_Client_Id=#{service_principal_id};Auth_Client_Secret=#{service_principal_secret};Auth_Scope=all-apis"
  end

  def import_data_in_batches(connection)
    offset = 0
    total_imported = 0

    loop do
      result_set = connection.execute("SELECT * FROM gold_staging.project_helios.events_raw LIMIT #{BATCH_SIZE} OFFSET #{offset}")

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

      imported = EventsRaw.import(events_raw_data, on_duplicate_key_update: { conflict_target: [:id], columns: [:updated_at] })
      total_imported += imported.ids.size

      offset += BATCH_SIZE

      Rails.logger.info "Batch Import: #{successful_imports} records imported successfully at #{DateTime.current.strftime('%d-%m-%Y %H:%M:%S')}."
      break if (Rails.env.test? ? successful_imports == BATCH_SIZE : successful_imports < BATCH_SIZE)
    end

    Rails.logger.info "Total Import: #{total_imported} records imported successfully in total at #{DateTime.current.strftime('%d-%m-%Y %H:%M:%S')}."
  end
end
