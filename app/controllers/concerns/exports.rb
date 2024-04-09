module Exports
  extend ActiveSupport::Concern

  require 'nkf'
  require 'csv'

  # 共通CSVエクスポート処理
  def export_csv(filename = nil, path = nil)
    send_data NKF::nkf('--sjis -Lw', render_to_string(path)),
              content_type: 'text/csv;charset=shift_jis',
              filename: filename_encode(filename)
  end

  def filename_encode(filename)
    if request.user_agent =~ /(MSIE|Trident)/
      ERB::Util.url_encode(filename)
    else
      filename
    end
  end
end
