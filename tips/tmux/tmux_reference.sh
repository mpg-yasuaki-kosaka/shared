" こういう感じで実行すると起動時に実行できる
$ alias tmux_='tmux new-session \; source-file ~/bin/tmux.sh'
$ tmux_

" キー送信、コマンド実行
send-keys 'rc' C-m
send-keys 'cdsa; bundle exec sidekiq -C config/sidekiq.yml' C-m
" window追加
new-window

" pane縦分割
splitw -v
" pane横分割
splitw -h

" pane選択
selectp -t 0
selectp -t 0
" resize 高さ１０行分にする
resize-pane -U 10

" windowの移動
move-window -t 0
ショートカットキー: prefixキー+.

" リネーム
rename-window "aaa"
ショートカットキー: prefixキー+,
