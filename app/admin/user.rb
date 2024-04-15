ActiveAdmin.register User, as: "Customer" do
    controller do
      defaults :resource_class => User
    end
  
    permit_params :email, :password, :password_confirmation, :referral_code, :referrer_reward, :referred_reward, :balance
  
    index do
      selectable_column
      id_column
      column :email
      column :balance
      column :created_at
      actions
    end
  
    form do |f|
      f.inputs do
        f.input :email
        f.input :password
        f.input :password_confirmation
        f.input :referral_code
        f.input :referrer_reward
        f.input :referred_reward
        f.input :balance
      end
      f.actions
    end
  end
  