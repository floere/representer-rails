class Presenters::Book < Presenters::Project
  model_reader :description

  def header
    model.title
  end
end
