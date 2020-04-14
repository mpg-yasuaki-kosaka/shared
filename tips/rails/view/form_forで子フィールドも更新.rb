# cocoonを使うのが良い

# view
= form_for @model, url: model_path, method: :put do |f|
  = f.fields_for :child_models do |child_models_form|
    = render "model_child_model_fields", f: child_models_form
  = link_to_add_fields "追加", f, :child_models

# helper
module ApplicationHelper
  def link_to_add_fields(name, f, association, prefix = "")
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(prefix + association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "#{prefix}add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end
end
