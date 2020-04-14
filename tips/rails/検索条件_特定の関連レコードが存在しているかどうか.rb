def user_image_exists(type: , exist_param: )
  not_exist = exist_param == "not_exist"
  where("users.id #{not_exist ? "NOT" : ""} IN " \
        "(SELECT user_id FROM user_images WHERE type = ?)", type)
end
scope = scope.merge( user_image_exists(type: params[:type], exist_param: params[:exist]) )
