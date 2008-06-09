class Presenters::Brain < Presenters::Product
  
  # Standard presenter method.
  # Looks nice…
  # url_for would work, too…
  # but can you spot the wet parts?
  #
  def description_line
    %Q{"#{model.former_host}", IQ #{model.iq} — #{model.price} EUR}
  end
  
  def description
    model.description
  end
  
end
