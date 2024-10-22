OpenAI.configure do |config|
  config.access_token    = Rails.application.credentials.openai[:access_token]
  config.organization_id = nil
  config.log_errors      = true
end
