# user -> user_images の場合
def image_count_by(params)
  from = params[:size_from].present? ? params[:size_from].to_i : 0
  to   = params[:size_to].present? ? params[:size_to].to_i : 1000
  scope = self
  scope = joins("INNER JOIN " \
                "( " \
                "  SELECT user_id, count(id) AS count" \
                "  FROM user_images" \
                "  GROUP BY user_id" \
                ") AS image_count " \
                "ON users.id = image_count.user_id")
  scope = scope.where("image_count.count BETWEEN #{from} AND #{to}")
  scope
end
scope.preload(:user_images)
scope.image_count_by(params[:user_image])
