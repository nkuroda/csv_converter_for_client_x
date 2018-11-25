require 'csv'
require 'yaml'

module ClientX
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

  # 指定のフォルダにあるCSVファイルをコンバート処理にかけて保存し、バックアップ処理を行うClass
  class Executor
    def initialize
      @config = YAML.load_file('config.yml')
      @source_dir = File.expand_path(@config['source_dir'])
      @dist_dir = File.expand_path(@config['dist_dir'])
      @backup_dir = File.expand_path(@config['backup_dir'])
    end

    def execute!
      target_file_paths = Dir.glob("#{@source_dir}/*.csv")
      target_file_paths.each do |target_file_path|
        target_file_name = File.basename(target_file_path)
        # まず変換後のCSVを取得し、dist_pathにファイル出力する
        converted_csv = ClientX::CsvConverter.new(file_path: target_file_path).convert!
        # prefix に `converted_` を付加したファイル名で保存する
        dist_file_name = "converted_#{target_file_name}"
        dist_file_path = File.expand_path(dist_file_name, @dist_dir)
        CSV.open(dist_file_path, 'w', encoding: 'CP932', force_quotes: true) do |csv|
          converted_csv.each do |csv_row|
            csv << csv_row
          end
        end
        # 処理完了したファイルはbackup_dirに移動する
        # prefix に `backuped_` を付加したファイル名で保存する
        backup_file_name = "backuped_#{target_file_name}"
        backup_file_path = File.expand_path(backup_file_name, @backup_dir)
        File.rename(target_file_path, backup_file_path)
      end
    end
  end
end
