require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TwgoExp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.time_zone = 'Asia/Taipei'
    config.i18n.default_locale = "zh-TW"
    config.my_hidden_branches = [
      'exp-testing',
      'gi_siann0102',
      'siann0102',
      'master',
      'print_info',
      '語言模型',
      '整理apt-get',
      'twisasa+tw01+tw02--ricer-baseline',
      'Jenkins_free-syllable-tw01test-仝語者_20180531104919',
      'Jenkins_free-syllable-tw01test-仝語者_20180531105622',
      'add_badge',
    ]
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
