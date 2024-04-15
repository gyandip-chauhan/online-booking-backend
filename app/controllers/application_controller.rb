# frozen_string_literal: true

class ApplicationController < ActionController::Base  
  before_action :authenticate_admin_user!
  before_action do
    ActiveStorage::Current.url_options = { protocol: request.protocol, host: request.host, port: request.port }
  end
end
