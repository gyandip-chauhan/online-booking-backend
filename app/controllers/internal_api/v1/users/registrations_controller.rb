# frozen_string_literal: true

class InternalApi::V1::Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token, only: [:create]
  respond_to :json

  def respond_with(user, _opts = {})
    if user.errors.present?
      render json: { error: user.errors }, status: :unprocessable_entity
    else
      render json: { notice: I18n.t("devise.registrations.signed_up"), email: user.email, user: user }, status: :ok
    end
  end
end
