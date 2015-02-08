CarrierWave.configure do |config|
  config.storage    = :aws
  config.aws_bucket = "vitae"
  config.asset_host = 'https://s3.amazonaws.com/vitae'
  config.aws_acl    = :public_read
  config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365

  config.aws_credentials = {
    access_key_id: ENV["AWS_PUBLIC"],
    secret_access_key: ENV["AWS_SECRET"]
  }
end