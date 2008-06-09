class Presenters::Book < Presenters::Product
  model_reader :description, :title, :pages, :price
  
  def description_line
    %Q{"#{title}", #{pages} S. — #{price} EUR}
  end
  
end
