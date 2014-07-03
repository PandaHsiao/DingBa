require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "csv"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module DingBa
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    #config.time_zone = 'Taipei'
    #config.i18n.default_locale = "zh-TW"
    config.exceptions_app = self.routes
    config.time_zone = 'Taipei'
    config.active_record.default_timezone = :local
    config.assets.enabled = true
    #config.assets.prefix = ''

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    #config.i18n.enforce_available_locales = true
    config.i18n.default_locale = "zh-TW"
    Week = ['星期一','星期二','星期三','星期四','星期五','星期六','星期日']
    Google_Driver_Login_P =  'koala4_fiat'

  end
end
