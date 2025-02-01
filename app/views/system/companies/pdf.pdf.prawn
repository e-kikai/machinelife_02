prawn_document(filename: "companies_seikyu.pdf") do |pdf|
  @companies.each do |co|
    # break if co.id != 1

    ### 金額計算 ###
    price, title =
      case co.rank
      when "special"; [80_000, "特別会員 年会費"]
      # when "branch"; next
      when "a_member"; [30_000, "A会員 年会費"]
      when "b_member"; [12_000, "B会員 年会費"]
      else; next
      end

    ### 請求書 ###
    pdf.start_new_page(margin: [0, 0, 0, 0])
    pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf"

    # pdf.default_leading 2

    pdf.image "app/assets/images/pdf/rank_seikyu_01.png", at: [0, 297.mm], width: 210.mm

    pdf.text_box "〒 #{co.zip_hyphen}\n#{co.addr}", at: [24.mm, 275.mm], size: 10
    pdf.text_box "#{co.company} 様", at: [24.mm, 263.mm], size: 16
    pdf.text_box "請求日 #{Date.current.strftime('%Y年%-m月%-d日')}", at: [134.mm, 275.mm], size: 10

    pdf.text_box "1/1", at: [26.mm, 197.mm], size: 10, valign: :center, height: 8.mm
    pdf.text_box title, at: [40.mm, 197.mm], size: 10, valign: :center, height: 8.mm
    pdf.text_box "1", at: [121.mm, 197.mm], size: 10, valign: :center, height: 8.mm
    pdf.text_box price.to_fs(:delimited), at: [132.mm, 197.mm], size: 10, valign: :center, height: 8.mm, width: 26.mm, align: :right
    pdf.text_box price.to_fs(:delimited), at: [158.5.mm, 197.mm], size: 10, valign: :center, height: 8.mm, width: 26.mm, align: :right
    pdf.text_box "(消費税 不課税)", at: [158.5.mm, 189.mm], size: 10, valign: :center, height: 8.mm, width: 26.mm, align: :right
    pdf.text_box price.to_fs(:delimited), at: [158.5.mm, 113.mm], size: 10, valign: :center, height: 8.mm, width: 26.mm, align: :right

    pdf.text_box Date.parse(params[:date]).strftime('%Y年%-m月%-d日'), at: [55.mm, 98.mm], size: 10

    pdf.line [55.mm, 94.mm], [85.mm, 94.mm]
    pdf.stroke

    pdf.image "app/assets/images/pdf/rank_seikyu_add_02.png", at: [36.mm, 85.mm], width: 140.mm
    pdf.image "app/assets/images/pdf/rank_seikyu_message.png", at: [36.mm, 31.mm], width: 100.mm

    # 追加 : 振込手数料はについて
    # pdf.bounding_box([100, 200], width: 300, height: 100) do
    #   stroke_bounds
    #   stroke_circle [0, 0], 10
    # end
    # pdf.fill_color 'FFFFFF'
    # pdf.rectangle [38.mm, 31.mm], 150.mm, 10.mm
    # pdf.fill

    # pdf.text_box "※ 振込の場合は、個人名ではなく会社名(屋号)でお願いします。", at: [38.mm, 31.mm], size: 10
    # pdf.text_box "※ 振込手数料は貴社負担でお願いします。", at: [38.mm, 27.mm], size: 10, inline_format: true
    # pdf.text('※ 振込の場合は、個人名ではなく')
    # pdf.font "vendor/assets/fonts/VL-PGothic-Regular.ttf", styles: [:bold]

    # pdf.text('会社名(<sub>屋号</sub>)', color: [22, 55, 79, 30], inline_format: true)
    # pdf.text('でお願いします')

    # formatted_text_box(
    #   [
    #     { text: 'Some bold. ', styles: [:bold] },
    #     { text: 'Some italic. ', styles: [:italic] },
    #     { text: 'Bold italic. ', styles: %i[bold italic] },
    #   ], at: [38.mm, 31.mm], size: 10
    # )

    ### 領収書 ###
    pdf.start_new_page
    pdf.image "app/assets/images/pdf/rank_seikyu_02.png", at: [0, 297.mm], width: 210.mm

    pdf.text_box "#{co.company} 様", at: [18.mm, 259.5.mm], size: 16
    pdf.text_box "1/1", at: [20.mm, 244.mm], size: 10, valign: :center, height: 9.mm
    pdf.text_box title, at: [36.mm, 244.mm], size: 10, valign: :center, height: 9.mm
    pdf.text_box price.to_fs(:delimited), at: [132.mm, 244.mm], size: 10, valign: :center, height: 9.mm, width: 50.mm, align: :right
    pdf.text_box "(消費税 不課税)", at: [133.mm, 235.mm], size: 10, valign: :center, height: 9.mm, width: 50.mm, align: :right
    pdf.text_box "#{price.to_fs(:delimited)}円", at: [133.mm, 195.mm], size: 12, valign: :center, height: 10.mm, width: 50.mm, align: :right

    # 領収証(控え)
    ratio = -146.5.mm
    pdf.text_box "#{co.company} 様", at: [18.mm, 259.5.mm + ratio], size: 16
    pdf.text_box "1/1", at: [20.mm, (244.mm + ratio)], size: 10, valign: :center, height: 9.mm
    pdf.text_box title, at: [36.mm, (244.mm + ratio)], size: 10, valign: :center, height: 9.mm
    pdf.text_box price.to_fs(:delimited), at: [132.mm, (244.mm + ratio)], size: 10, valign: :center, height: 9.mm, width: 50.mm, align: :right
    pdf.text_box "(消費税 不課税)", at: [133.mm, (235.mm + ratio)], size: 10, valign: :center, height: 9.mm, width: 50.mm, align: :right
    pdf.text_box "#{price.to_fs(:delimited)}円", at: [133.mm, (195.mm + ratio)], size: 12, valign: :center, height: 10.mm, width: 50.mm, align: :right

    pdf.line [18.mm, 253.mm], [110.mm, 253.mm]
    pdf.line [18.mm, 253.mm + ratio], [110.mm, 253.mm + ratio]
    pdf.stroke
  end
end
