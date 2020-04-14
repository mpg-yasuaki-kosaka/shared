# controller
  def index
    respond_to do |format|
      format.html {}
      format.csv {
        send_data render_to_string, filename: CSV_FILE_NAME, type: 'text/csv; charset=shift_jis'
      }
    end
  end


# view **/index.csv.ruby
header = %w(a b c d e)
csv = CSV.generate(row_sep: "\r\n") do |row|
  row << header
  @models.each do |model|
    row << [
      model.id,
      ...
    ]
  end
end
csv.encode(Encoding::SJIS, invalid: :replace, undef: :replace, replace: "?")
