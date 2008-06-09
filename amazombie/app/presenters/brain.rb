class Presenters::Brain < Presenters::Product
  
  def description_line
    %Q{"#{model.former_host}", IQ #{model.iq} — #{model.price} EUR}
  end
  
  def description
    model.description
  end
  
end
