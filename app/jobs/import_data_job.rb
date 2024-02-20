class ImportDataJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 0

  BATCH_SIZE = 100000

  def perform
    begin
      delete_records_in_batches
      import_new_data
    rescue => e
      Rails.logger.error "An error occurred during import: #{e.message}"
    end
  end

  private

  def delete_records_in_batches
    total_records_deleted = 0
    begin
      loop do
        records_deleted = EventsRaw.limit(BATCH_SIZE).delete_all
        break if records_deleted == 0
        total_records_deleted += records_deleted
      end
    rescue => e
      Rails.logger.error "An error occurred while deleting records: #{e.message}"
      raise e
    end
    Rails.logger.info "#{total_records_deleted} records deleted at #{DateTime.current.strftime('%d-%m-%Y %H:%M:%S')}."
  end

  def import_new_data
    odbc_connection = OdbcConnection.new
    odbc_connection.import_data
  end
end
