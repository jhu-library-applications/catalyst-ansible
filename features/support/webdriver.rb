require 'selenium-webdriver'
require 'capybara/cucumber'
require 'rspec/expectations'

driver = :headless_chrome # :headless_chrome :selenium :selenium_chrome and :selenium_chrome_headless

# NOTE: i'm not sure there's any difference between our :headless_chrome and the provided :selenium_chrome_headless
if driver == :headless_chrome
  Capybara.register_driver(driver) do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
        chromeOptions: { args: %w[headless disable-gpu] }
    )

    Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
  end
end

Capybara.configure do |config|
  config.run_server = false
  config.default_driver = driver
end

Capybara.javascript_driver = driver
