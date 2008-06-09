class Presenters::Product < Presenters::Project
  model_reader :textile_description, :filter_through => :textilize
  
end
