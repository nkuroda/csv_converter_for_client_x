require 'csv'

# 以下のClassは税抜合計金額(19番目のカラム)、税込合計金額(20番目のカラム)、消費税合計額(21番目のカラム)が、
# 集計単位で先頭行のみにしか出力されていないが、それらをその他の行にも補完する処理を行うclassである。
class CsvConverter
  # @param [String] file_path
  def initialize(file_path:)
    @file_path = file_path
  end

  # 変換したcsvを返す
  # @return [Array<Array>]
  def convert!
    csv = read_csv
    unit_number = nil # csv行の紐づく集計番号
    total_exclude_tax_value = nil # 税抜合計金額
    total_include_tax_value = nil # 税込合計金額
    total_tax_value = nil # 合計消費税額

    csv.each do |csv_row|
      # 集計番号が前行とアンマッチの場合、税抜合計金額、税込合計金額、合計消費税額を更新
      if unit_number != csv_row[2]
        total_exclude_tax_value = csv_row[18]
        total_include_tax_value = csv_row[19]
        total_tax_value = csv_row[20]
        unit_number = csv_row[2]
      end

      # 全ての行で税抜合計金額、税込合計金額、合計消費税額を更新
      csv_row[18] = total_exclude_tax_value
      csv_row[19] = total_include_tax_value
      csv_row[20] = total_tax_value
    end
  end

  private

  # ファイルをCP932で読み込み、csvを2次元配列で返す
  # @return [Array<Array>]
  def read_csv
    read_string = File.read(@file_path, encoding: 'CP932')
    CSV.parse(
      read_string,
      headers: nil,
      converters: nil
    )
  end
end
