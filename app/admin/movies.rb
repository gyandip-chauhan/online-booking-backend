# app/admin/movie.rb
ActiveAdmin.register Movie do
  permit_params :title, :description, :avatar, :movie_category_id, :trailer_url, 
                movie_cast_and_crews_attributes: [:id, :movie_id, :name, :kind, :role, :image, :_destroy]
  filter :title
  filter :movie_category
  filter :description

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
    column :trailer_url
    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :description
      row :avatar do |movie|
        if movie.avatar.attached?
          image_tag(url_for(movie.avatar), style: 'width: 50px;
            height: 50px;
            object-fit: cover;
            border-radius: 50%;')
        else
          content_tag(:span, 'No avatar yet')
        end
      end
      row :movie_category
      row :trailer_url
    end
    panel 'Cast and Crew' do
      table_for movie.movie_cast_and_crews do
        column :id
        column :name
        column :kind
        column :role
        column :image do |cast_and_crew|
          if cast_and_crew.image.attached?
            image_tag(url_for(cast_and_crew.image), style: 'width: 50px;
              height: 50px;
              object-fit: cover;
              border-radius: 50%;')
          else
            content_tag(:span, 'No image yet')
          end
        end
      end
    end
  end

  form do |f|
    f.inputs 'Movie Details' do
      f.input :title
      f.input :movie_category, as: :select, collection: MovieCategory.all.map { |mc| [mc.name, mc.id] }
      f.input :description
      f.input :avatar, as: :file, input_html: { accept: 'image/*' }, hint: f.object.avatar.attached? ? image_tag(url_for(f.object.avatar), style: 'width: 50px;
          height: 50px;
          object-fit: cover;
          border-radius: 50%;') : content_tag(:span, 'No avatar yet')
      f.input :trailer_url
    end

    f.inputs 'Cast and Crew' do
      f.has_many :movie_cast_and_crews, heading: 'Cast and Crew', allow_destroy: true do |cast_and_crew|
        cast_and_crew.input :name
        cast_and_crew.input :kind, as: :select, collection: MovieCastAndCrew.kinds.keys
        cast_and_crew.input :role, as: :select, collection: MovieCastAndCrew.roles.keys
        cast_and_crew.input :image, as: :file, input_html: { accept: 'image/*' }, hint: cast_and_crew.object.image.attached? ? image_tag(url_for(cast_and_crew.object.image), style: 'width: 50px;
        height: 50px;
        object-fit: cover;
        border-radius: 50%;') : content_tag(:span, 'No image yet')
      end
    end

    f.actions
  end
end
