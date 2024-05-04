class Mailchimp
  attr_accessor :client

  def initialize(list_name = nil)
    @client = MailchimpMarketing::Client.new
    @client.set_config(
      {
        api_key: Rails.application.credentials.mailchimp[:api_key],
        server: Rails.application.credentials.mailchimp[:server]
      }
    )

    @list_id = Rails.application.credentials.mailchimp.fetch(list_name == :admin ? :admin_list_id : :list_id)
  end

  def set_list_member(mail, fields = {})
    @client.lists.set_list_member(
      @list_id,
      Digest::MD5.hexdigest(mail),
      {
        email_address: mail,
        status: :subscribed,
        merge_fields: fields
      }
    )
  end
end
