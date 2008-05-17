class Brain
  
  attr_reader :weight, :type
  
  def initialize(weight)
    @weight = weight
  end
  
  def type
    ['beautiful, beautiful, beaaaauuuuuuutiful', 'incredibly tasty, yet supple', 'gleaming'][rand(3)]
  end
  
end