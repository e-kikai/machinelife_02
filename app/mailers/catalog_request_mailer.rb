class CatalogRequestMailer < ApplicationMailer
  def request_mail(catalog_request, to: nil, from: nil)
    @catalog_request = catalog_request
    @to = to

    mail(
      to: @to.mail,
      reply_to: from.mail,
      subject: "マシンライフ: カタログを探しています"
    )
  end
end
