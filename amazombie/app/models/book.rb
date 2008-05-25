class Book < Product
  attr_accessor :author, :title, :description
  
  def initialize
    @title = title_generator
  end
  
  def title_generator
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
    words = %w{Brain Chainsaw Skull Zombie Eyesoup Living\ Dead Voodoo}
    phrases[rand(phrases.size)] % words.sort_by(&:rand)
  end
  
end
