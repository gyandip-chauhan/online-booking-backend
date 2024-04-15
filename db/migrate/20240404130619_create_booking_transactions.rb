class CreateBookingTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :booking_transactions do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :stripe_payment_id
      t.string :payment_provider
      t.integer :status, default: 0
      t.integer :amount

      t.timestamps
    end
    add_column :users, :stripe_id, :string
    add_column :bookings, :stripe_payment_method_id, :string
    add_column :bookings, :source, :string
    add_column :bookings, :status, :integer, default: 0
    add_column :bookings, :stripe_payment_confirmed_at, :datetime
  end
end
