require "watir"

When(/^I enter "([^"]*)" into the search box$/) do |search_term|
  @browser.text_field(:id => "q").set search_term
end

When(/^I click "([^"]*)"$/) do |button_text|
  @browser.button(:text => button_text ).click
end

Then(/^I should see "([^"]*)" in a link$/) do |link_text|
  expect(@browser.link(text: /#{link_text}/)).to exist
  # links = @browser.links
  # links.each do |l|
  #   if l.text.downcase.match(/#{link_text}/i)
  #     # @title_link ||= l
  #     expect(l).to exist
  #   end
  # end
end

Then(/^I click on a link having partial text "([^\"]*)"$/) do |partial_text|
# Then(/^I click on a link having partial text "([^"]*)"$/) do |partial_text|
  # @browser.driver.find_element(:partial_link_text, partial_text).click
  @browser.link(:text => /#{partial_text}/).wait_until_present
  @browser.link(:text => /#{partial_text}/).click
  # links = @browser.links
  # links.each do |l|
  #   if l.text.downcase.match(/#{partial_text}/i)
  #     l.click
  #     # l.fire_event('click')
  #   end
  # end
  # @title_link.click
end

Then(/^I should see "([^"]*)" header$/) do |partial_text|
  expect(@browser.h1(:class => "show-marc-heading-title", :text => /#{partial_text}/)).to exist
end
