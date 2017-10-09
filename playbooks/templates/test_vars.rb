module TestingEnvironment
  class << self
    attr_accessor :catalyst_url, :findit_ip
  end
  self.catalyst_url = "http://{{ groups['catalyst'][0] }}"
  self.findit_ip = "{{ findit_ip }}"
end
