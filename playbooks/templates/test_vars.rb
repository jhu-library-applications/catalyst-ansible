# environment vars: doesn't matter how it gets set
ENV["CATALYST_URL"]="http://{{ groups['catalyst'][0] }}"

# simple syntax:
FINDIT_IP="{{ findit_ip }}"

# clearly a global var. global vars are usually bad, though
$findit_ip = "{{ findit_ip }}"

# encapsulation and abstraction at the cost of complexity
module TestingEnvironment
  class << self
    attr_accessor :catalyst_url, :findit_ip
  end
  self.catalyst_url = "http://{{ groups['catalyst'][0] }}"
  self.findit_ip = "{{ findit_ip }}"
end
