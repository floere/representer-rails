class Brain < Product
  attr_accessor :weight, :former_host
  
  def initialize
    @weight = 800 + rand(700)
  end
  
end