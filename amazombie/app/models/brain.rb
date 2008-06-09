class Brain < Product
  attr_accessor :former_host, :iq
  
  def initialize
    @iq = 80 + rand(40)
    @former_host = Faker::Name.name
    @price = 119 + rand(499)
  end
  
  # This is an example how absolutely NOT to do it
  #
  def description_line
    %Q{"#{former_host}", IQ #{iq} &mdash; #{price} EUR}
  end
  # 
  # and btw: ever tried to use url_for in a model?
  
end