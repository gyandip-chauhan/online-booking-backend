class BookingNotifier < ApplicationNotifier
  deliver_by :email do |config, options|
    config.mailer = "UserMailer"
    config.method = "new_booking"
  end

  deliver_by :twilio_messaging, format: :format_for_twilio do |config|
    config.credentials = {
      phone_number: ENV['TWILIO_ACCOUNT_PHONE_NUMBER'],
      account_sid: ENV['TWILIO_ACCOUNT_SID'],
      auth_token: ENV['TWILIO_AUTH_TOKEN']
    }
  end

  def format_for_twilio
    {
      From: phone_number,
      To: recipient.phone_number,
      Body: params[:message]
    }
  end

  notification_methods do
    def message
      params[:message]
    end
  end
end
