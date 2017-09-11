Given(/^I need to test my variables$/) do
  # environment vars: doesn't matter how it gets set
  p "ENV['CATALYST_URL'] = " + ENV['CATALYST_URL']

  # simple syntax:
  p "FINDIT_IP = " + FINDIT_IP

  # clearly a global var. global vars are usually bad, though
  p "$findit_ip = #{$findit_ip}"

  # encapsulation and abstraction at the cost of complexity
  p "TestingEnvironment.catalyst_url  =  #{TestingEnvironment.catalyst_url}"
  p "TestingEnvironment.findit_ip     =  #{TestingEnvironment.findit_ip}"
end
