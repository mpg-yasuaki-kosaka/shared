Model.unscoped

default_scopeの指定が複数あり、一部分削除したいところがある場合は、
Model.unscope([default_scopeで削除したい範囲])
でOK。

ex)
Model.unscope(where: :deleted_at)
