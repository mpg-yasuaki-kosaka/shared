

simple_form
カラムの型を自動で判別して適切なフィールドを出力する。
integrはnumber_fieldだが、enumまたはenumerizeが設定されているとそれも自動で反映してselectで出力する。

https://qiita.com/tomomomo1217/items/09d791363364a876996f
・必須のマークをラベル右側に出す
・エラーメッセージをフルメッセージで出す

Rails: simple_formの日本語エラーメッセージに主語をつける方法
https://suin.io/546

チェックボックスにする　https://teratail.com/questions/100499
= f.input :remove_main_image, as: :boolean
