@ECHO OFF
REM +--------------------------------------------------------------------+
REM | DESCRIPTION: | このWindowsバッチは `csv_convertor.rb` スクリプトを呼び出して終了するバッチです
REM +--------------+-----------------------------------------------------+

REM このバッチが存在するフォルダに移動し、そこを基点にする（バッチファイルは `csv_convertor.rb`と同一ディレクトリに配置してください）
pushd %~dp0

ruby csv_converter.rb

EXIT
