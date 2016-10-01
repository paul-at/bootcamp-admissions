class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  # Adapted from https://www.yihangho.com/rails-cross-origin-resource-sharing/
  def self.allow_cors(*methods)
    before_action :cors_before_filter, only: methods

    skip_before_action :verify_authenticity_token, only: methods
    skip_before_action :authenticate_user!, only: methods
  end

  private

  def cors_before_filter
    return unless Rails.application.config.cors
    return unless request.headers['Origin']
    Rails.application.config.cors.each do |host|
      ['http://', 'https://'].each do |protocol|
        full_host = protocol + host
        if request.headers['Origin'][0..(full_host.length-1)] == full_host
          headers['Access-Control-Allow-Origin'] = request.headers['Origin']
        end
      end
    end
  end
end
