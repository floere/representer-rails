class Presenters::Book < Presenters::Product
  model_reader :description, :title, :pages, :price
  
  def description_line
    %Q{"#{title}", #{pages} S. &mdash; #{price} EUR}
  end
  
end
