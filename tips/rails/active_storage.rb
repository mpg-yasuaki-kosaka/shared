# 前提
modelに
has_one_attached :file
がある

# 添付保存 - ミニマム
f=File.open('/Users/yamada.tarou/Downloads/test.txt')
model.file.attach(io: f, filename: 'test.txt', content_type: 'text/plain')

# レコード保存 → PDF(Thinreports)をStringIOでファイル添付 → 保存
report = Thinreports::Report.new
...
report.generate # → Stringになるっぽい

model = Model.new( hash )
model.save # 先にsaveする
model.file.attach(io: StringIO.new(report), filename: 'temp.pdf', content_type: 'application/pdf')

# レコード保存 → PDF(Thinreports)をTempfile化 → ファイル添付 → 保存
report = Thinreports::Report.new
...
report.generate # → Stringになるっぽい

model = Model.new( hash )
model.save # 先にsaveする

temp_file = Tempfile.new('temp_file.pdf')
temp_file.write report.force_encoding("UTF-8")
temp_file.open
model.file.attach(io: temp_file, filename: 'test.pdf', content_type: 'application/pdf')
temp_file.close

# ActiveStorageのダウンロード
https://haayaaa.hatenablog.com/entry/2019/02/22/225426
model.file.download

# コンソールでレコードからファイルを取得する
path = "#{Dir.tmpdir}/test3.pdf"
File.open(path, 'wb') do |file|
  file.write(model.file.download)
end

