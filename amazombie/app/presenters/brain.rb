class Presenters::Brain < Presenters::Project
  
  # Standard presenter method.
  # Looks nice…
  # url_for would work, too…
  # but can you spot the wet parts?
  #
  def description_line
    %Q{"#{model.former_host}", IQ #{model.iq} &mdash; #{model.price} EUR}
  end
  
  def description
    model.description
  end
  
end
