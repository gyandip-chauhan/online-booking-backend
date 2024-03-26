class ImportDataJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 0

  # DELETE_BATCH_SIZE = 100000

  def perform
    # delete_records_in_batches
    import_new_data
  end

  private

  # def delete_records_in_batches
  #   total_records_deleted = 0
  #   loop do
  #     records_deleted = BxBlockEventsRaw::EventsRaw.limit(DELETE_BATCH_SIZE).delete_all
  #     break if records_deleted == 0
  #     total_records_deleted += records_deleted
  #     Rails.logger.info "Batch Delete: #{records_deleted} records deleted at #{DateTime.current.strftime('%d-%m-%Y %H:%M:%S')}."
  #   end
  #   Rails.logger.info "Total Delete: #{total_records_deleted} records deleted at #{DateTime.current.strftime('%d-%m-%Y %H:%M:%S')}."
  # end

  def import_new_data
    odbc_connection = OdbcConnection.new
    odbc_connection.import_data
  end
end
