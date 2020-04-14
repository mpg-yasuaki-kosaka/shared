# rescueの再利用
rescue_from ActiveRecord::RecordNotFound do |exception|
  redirect_to :root, alert: 'User not found'
end
# をdefと同じレベルに置く
# もしくは
rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_homepage
private
def redirect_to_homepage
  redirect_to :root, alert: 'User not found'
end

--
スパゲッティになるのであまり使わないほうが良い
