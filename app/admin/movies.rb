# app/admin/movie.rb
ActiveAdmin.register Movie do
  permit_params :title, :description, :avatar, :movie_category_id

  index do
    selectable_column
    id_column
    column :title
    column :movie_category
    column :description
    column :avatar do |movie|
      if movie.avatar.attached?
        image_tag(url_for(movie.avatar), style: 'width: 50px;
          height: 50px;
          object-fit: cover;
          border-radius: 50%;')
      else
        content_tag(:span, 'No avatar yet')
      end
    end
    actions
  end

  filter :title
  filter :movie_category
  filter :description

  form do |f|
    f.inputs do
      f.input :title
      f.input :movie_category, as: :select, collection: MovieCategory.all.map { |mc| [mc.name, mc.id] }
      f.input :description
      f.input :avatar, as: :file, hint: f.object.avatar.attached? ? image_tag(url_for(f.object.avatar), style: 'width: 50px;
          height: 50px;
          object-fit: cover;
          border-radius: 50%;') : content_tag(:span, 'No avatar yet')
    end
    f.actions
  end
end
