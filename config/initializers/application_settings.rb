Rails.application.config.allow_faker = ENV['ALLOW_FAKER'] || false
Rails.application.config.cors = ENV['CORS_DOMAINS'] ? ENV['CORS_DOMAINS'].split(',') : []
Rails.application.config.uploads_max_size = 5.megabytes