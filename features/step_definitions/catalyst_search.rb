# require "watir"

When(/^I enter "([^"]*)" into the search box$/) do |search_term|
  # @browser.text_field(:id => "q").set search_term
  # within('#q') do
    # fill_in '#q', with: search_term
    fill_in(:id => 'q', with: search_term)
  # end
end

When(/^I click "([^"]*)"$/) do |button_text|
  # @browser.button(:text => button_text ).click
  click_on(button_text)
end

When(/^I click on an item link which reads "([^"]*)"$/) do |partial_text|
  # @browser.link(:text => /#{partial_text}/).click
  click_link(partial_text)
end

When(/^I click on a link for item "([^"]*)" which reads "([^"]*)"$/) do |bib_number, partial_text|
  find_link(text: /#{partial_text}/, href: /#{bib_number}/).click
end

Then(/^I should be taken to a search results page$/) do
  # TODO: figure out a way to check this that works for all the search possibilities
  # OR break up the scenarios for each search type
end

Then(/^I should be taken to a detail page for the item with bib number "([^"]*)"$/) do |bib_number|
  # expect(@browser.url).to include(bib_number)
  expect(page.current_path).to include(bib_number)
end

Then(/^I should see "([^"]*)" on the page$/) do |page_text|
  # expect(@browser.body.inner_html).to include(page_text)
  expect(page).to have_content(page_text)
end

Then(/^I should see "([^"]*)" in a link$/) do |link_text|
  # expect(@browser.link(text: /#{link_text}/)).to exist
  # expect(find_link(text: /#{link_text}/)).to exist
  expect(page).to have_link(text: /#{link_text}/)
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
  # @browser.link(:text => /#{partial_text}/).wait_until_present
  # @browser.link(:text => /#{partial_text}/).click
  find_link(text: /#{link_text}/).click
  # links = @browser.links
  # links.each do |l|
  #   if l.text.downcase.match(/#{partial_text}/i)
  #     l.click
  #     # l.fire_event('click')
  #   end
  # end
  # @title_link.click
end

Then(/^I should see "([^"]*)" in the header$/) do |partial_text|
  # expect(@browser.h1(:class => "show-marc-heading-title", :text => /#{partial_text}/)).to exist
  expect(page).to have_selector("h1.show-marc-heading-title", :text => /#{partial_text}/)
end
