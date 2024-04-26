module InternalApi::V1
  class NotificationSerializer < ApplicationSerializer
    attributes :id, :type, :event_id, :recipient_type, :recipient_id, :read_at, :seen_at, :created_at, :updated_at

    attributes :message do |object|
      object.message
    end
  end
end
