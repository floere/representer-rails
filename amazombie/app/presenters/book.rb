class Presenters::Book < Presenters::Project
  model_reader :description

  def description_line
    %Q{"#{model.title}", #{model.pages} S. &mdash; #{model.price} EUR}
  end

end
