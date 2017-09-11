# environment vars: doesn't matter how it gets set
ENV["CATALYST_URL"]="http://catalyst.test"

# simple syntax:
FINDIT_IP="10.11.12.102"

# clearly a global var. global vars are usually bad, though
$findit_ip = "10.11.12.102"

# encapsulation and abstraction at the cost of complexity
module TestingEnvironment
  class << self
    attr_accessor :catalyst_url, :findit_ip
  end
  self.catalyst_url = "http://catalyst.test"
  self.findit_ip = "10.11.12.102"
end
