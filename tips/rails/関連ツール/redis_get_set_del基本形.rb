# あまりredisへのデータ保存はしないほうが良いかも
# 特段の理由がなければ、DB,elasticsearch,cookieなど別の方法を検討すべき
redis = Redis.new
views = redis.get( 'idなどをもたせたユニークなキー' )
views = views == nil ? [] : JSON.parse(views)
views


redis.set( 'idなどをもたせたユニークなキー', views.to_json)
