# app/controllers/internal_api/v1/notifications_controller.rb

module InternalApi::V1
  class NotificationsController < ApplicationController
    before_action :set_notifications

    def index
      notifications_data
    end

    def mark_as_read
      if params[:notification_id].present?
        @notification = @notifications.find(params[:notification_id])
        @notification.mark_as_read!
        notifications_data('Notification marked as read successfully.')
      else
        @notifications.mark_as_read
        notifications_data('All notifications marked as read successfully.')
      end
    end

    private

    def set_notifications
      @notifications = current_user.notifications.includes(event: :record).order('updated_at DESC')
    end

    def notifications_data(notice = nil)
      data = { notifications: NotificationSerializer.new(@notifications), unread_count: @notifications.unread.count }
      data[:notice] = notice if notice.present?
      render json: data, status: :ok
    end
  end
end
