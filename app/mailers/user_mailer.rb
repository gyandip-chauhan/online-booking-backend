class UserMailer < Devise::Mailer
  default from: "<#{ENV['DEFAULT_FROM_EMAIL']}>"
  
  def reset_password_instructions(record, token, opts={})
    super
  end

  def confirmation_instructions(record, token, opts={})
    super
  end

  # private

  # def add_inline_attachments!
  #   attachments.inline['your-logo.png'] = File.read(Rails.root.join('app/assets/images/your-logo.png'))
  # end
end
