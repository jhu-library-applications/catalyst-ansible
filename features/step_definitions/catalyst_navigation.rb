# require "watir"
# require "dotenv/load"
#require "headless"
# require "rspec/expectations"

Given(/^I go to Catalyst$/) do
  # @browser ||= Watir::Browser.new
  # @browser.window.maximize
  # @browser.goto ENV['CATALYST_URL']
  visit ENV['CATALYST_URL']
  #puts "Load Time: #{browser.performance.summary[:response_time]/1000} seconds."
end

When /^I click on the "([^"]*)" link$/ do |link_text|
  # @browser.link(:text => link_text).click
  click_on(link_text)
  # find_link(:text => link_text).click
end

When(/^I am not logged in$/) do
  # NOTE: not sure about this implementation
  # expect(@browser.link(:text => "Login")).to exist
  expect(page).to have_link("Login")
end

And(/^I maximize my browser$/) do
  # @browser.window.maximize
  page.driver.browser.manage.window.maximize
end

When(/^I resize my browser to (\d+) by (\d+)$/) do |width, height|
  # @browser.window.resize_to(width,height)
  page.driver.browser.manage.window.resize_to(width,height)
end

Then(/^I should see the "([^"]*)" form$/) do |form_class|
  # expect(@browser.form(:class => form_class)).to exist
  # either will work:
  expect(page).to have_css("form.#{form_class}")
  # OR
  # expect(page.has_css?("form.#{form_class}")).to be true
end

Then(/^I should see an alert$/) do
  # expect(@browser.div(:class => "alert-info")).to exist
  expect(page).to have_css("div.#{alert-info}")
end

Then(/^I should see the alert, "([^"]*)"$/) do |alert_text|
  # expect(@browser.div(:class => "alert-info").text).to include(alert_text)
  expect(find('div.alert-info')).to have_content(alert_text)
  # expect(page).to have_css(".div.#{alert-info}").to have_content(alert_text)
end

Then(/^I should see the text "([^"]*)"$/) do |text|
  expect(@browser.body.inner_html).to include(text)
end

Then(/^I should see "([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end
