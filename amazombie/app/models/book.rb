class Book < Product
  attr_accessor :author, :title, :description, :pages
  
  def initialize(zombie=false)
    @title = title_generator(zombie)
    @pages = 190 + rand(700)
    @price = 19 + rand(20)
  end
  
  # This is an example how absolutely NOT to do it
  #
  def description_line
    %Q{"#{title}", #{pages} S. &mdash; #{price} EUR}
  end
  
  def title_generator(zombie)
    phrases = [
      '%ss in a Nutshell',
      'Short Guide to %ss',
      'Rapid %s Development on %ss',
      '%s Way to %ss',
      '%ss in 21 Days',
      '%s Recipes',
      'The Pragmatic %s',
      'Beginning %s: From Novice to Professional',
      'Agile %s Development with %ss',
      'Enterprise Integration with %ss',
      '%s by Example: %ss and %ss',
      'The %s Bible',
      'Gardening with %s (aka The Pickaxe)'
    ]
    words = %w{Ruby Python Smalltalk Java Javascript Rails}
    words = %w{Brain Chainsaw Skull Zombie Eyesoup Living\ Dead Voodoo} if zombie
    phrases[rand(phrases.size)] % words.sort_by(&:rand)
  end
  
end
