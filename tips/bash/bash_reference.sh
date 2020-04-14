#!/bin/bash
# bashコマンド、シェルスクリプトよく使うリファレンス

# カレントブランチの取得
branch=`git branch | grep \* | awk '{print $2}'`

# nullチェック
if [ -z "$branch" ]; then
  # ...
fi

# not null チェック
if [ ! -z "$num" ]; then
  # ...
fi;

# 正規表現で抽出
title=`echo "${branch}" | perl -pe "s/_DT-\d+//"`

# if 含む
if [ `echo 'hogefuga' | grep 'fuga'` ] ; then
  echo 'ok'
fi

# 引数なし
if [ -z "$@" ]; then
  echo "引数がありません怒";
  exit 0
fi;

# each
repos=("branch1" "branch2" "branch3" "branch4")
for repo in ${repos[@]}; do
  # ...
done

# スペースを含む引数をコマンドにすべて渡す
msg=$@
git commit -m "$msg"

# コピー
moto_dir="${HOME}/bin"
saki_dir="${HOME}/repos/dev"
# フォルダごと
cp -r "${moto_dir}/scripts" "${saki_dir}"
# ファイル
cp "${HOME}/.gitconfig" "${saki_dir}/configs"

# ファンクション定義 エイリアス代わりにも
function ggd(){ git grep $@ -- db }

