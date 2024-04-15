ActiveAdmin.register Booking do
    permit_params :user_id, :showtime_id, :total_price, :is_cancelled, :stripe_payment_method_id, :source, :status, :stripe_payment_confirmed_at
  
    show do
      attributes_table do
        row :user
        row :showtime
        row :total_price
        row :is_cancelled
        row :stripe_payment_method_id
        row :source
        row :status
        row :stripe_payment_confirmed_at
      end
  
      panel "Booking Transactions" do
        table_for booking.booking_transactions do
          column :id
          column :user
          column :stripe_payment_id
          column :payment_provider
          column :status
          column :amount
          column :created_at
          column :updated_at
        end
      end
  
      panel "Booked Seats" do
        table_for booking.booked_seats do
          column :id
          column :seat_category
          column :seats
          column :created_at
          column :updated_at
        end
      end
    end
  
    form do |f|
      f.inputs "Booking Details" do
        f.input :user
        f.input :showtime
        f.input :total_price
        f.input :is_cancelled
        f.input :stripe_payment_method_id
        f.input :source
        f.input :status
        f.input :stripe_payment_confirmed_at
      end
      f.actions
    end
  end
  