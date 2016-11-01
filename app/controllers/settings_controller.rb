class SettingsController < ApplicationController
  authorize_resource
  before_action do |controller|
    @settings_page = true
  end

  def index
    @settings = Setting.get_all
  end

  def update
    params[:settings].each do |setting,value|
      value = apply_types(value, Setting[setting.to_s])
      setting = setting.to_s
      if Setting[setting] != value
        Setting[setting] = value
      end
    end
    redirect_to settings_path, notice: 'Settings updated'
  end

  private
  def apply_types(value, example)
    if example.is_a?(Hash)
      unless value.is_a?(ActionController::Parameters)
        raise "Cannot convert #{value.class} to a Hash"
      end
      result = Hash.new
      example.to_h.each do |subkey, subvalue|
        result[subkey.to_sym] = apply_types(value[subkey], subvalue)
      end
      return result
    else
      if example.is_a?(Integer)
        return value.to_i
      elsif [true, false].include?(example)
        return value == 'true'
      else
        return value.to_s
      end
    end
  end
end
