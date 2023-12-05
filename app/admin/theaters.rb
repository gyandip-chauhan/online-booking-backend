ActiveAdmin.register Theater do
  permit_params :name, :location

  index do
    selectable_column
    id_column
    column :name
    column :location
    actions
  end

  filter :name
  filter :location

  form do |f|
    f.inputs do
      f.input :name
      f.input :location
    end
    f.actions
  end
end
