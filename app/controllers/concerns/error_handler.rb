# frozen_string_literal: true

module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::RoutingError, ActiveRecord::RecordNotFound, with: :handle_not_found_error
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  end

  private

  def handle_not_found_error(exception)
    message = exception.message || I18n.t("errors.not_found")

    respond_to do |format|
      format.json { render json: { errors: message }, status: :not_found }
      format.html { render file: "public/404.html", status: :not_found, layout: false, alert: message }
    end
  end

  def record_invalid(exception)
    message = exception.message

    respond_to do |format|
      format.json {
        render json: {
                  errors: exception.record.errors.full_messages.first,
                  notice: I18n.t("client.update.failure.message")
                },
          status: :unprocessable_entity
      }
      format.html { render file: "public/422.html", status: :unprocessable_entity, layout: false, alert: message }
    end
  end
end
