
puma dev 使い方, 開発環境でのhttpsの設定

# 初期設定
# puma-dev -uninstall (ドメインを変える際)
puma-dev -install -d test
cd ~/.puma-dev/
ln -s ~/repos/repo1 repo1

# ssl許可 key作成
openssl genrsa -out ./localhost.key 2048
sudo openssl req -new -x509 -key ./localhost.key -out ./localhost.crt -days 3650 -subj /CN=localhost\n

# 起動
bundle exec puma -C config/puma.rb -b 'ssl://repo1.test:3001?key=/Users/user/server.key&cert=/Users/
user/server.crt'

# httpsにするだけなら
# bundle exec puma -C config/puma.rb -b 'ssl://localhost:3001?key=/Users/user/server.key&cert=/Users/user/server.crt'

# webpackもhttpsで動かす
bin/webpack-dev-server --https

config/webpacker.yml
development > dev-server > https: true

# thinなら
bundle exec thin start --ssl -p 3001

# ドメインの名前解決がおかしくなったら
rm /etc/resolver/com

# 使えるかも
http://xip.io/

# 画面が白くなったり表示が崩れるときは
cssやjsファイルが正しく取得できているか確認、直接開いてみる。

# 設定まとめ
・httpsの開発環境URL
・google,facebookのアカウント
・https://console.developers.google.com と https://developers.facebook.com でのアプリ登録/認証設定
両サービス`https://localhost:3001`で設定中。

assetsファイルのエラー回避: config/webpacker.yml > development > dev_server > https: true
画面を開いてコンソール確認 > js,cssファイルが直接開けるか確認
