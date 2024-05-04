CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

CarrierWave.configure do |config|
  if Rails.env.development?
    config.storage = :file
  else
    config.fog_credentials =
      {
        provider: 'AWS',
        aws_access_key_id: Rails.application.credentials.aws[:access_key_id],
        aws_secret_access_key: Rails.application.credentials.aws[:secret_access_key],
        region: 'ap-northeast-1', # Tokyo
        path_style: true
      }

    config.storage        = :fog
    config.fog_public     = true # public-read
    config.fog_attributes = { 'Cache-Control' => 'public, max-age=86400' }

    config.fog_directory = Rails.application.credentials.aws[:aws_s3_bucket]
    config.asset_host    = "https://s3-ap-northeast-1.amazonaws.com/#{Rails.application.credentials.aws[:aws_s3_bucket]}"
  end
end
