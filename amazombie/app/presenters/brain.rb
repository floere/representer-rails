class Presenters::Brain < Presenters::Project
  
  model_reader :weight, :filter_through => :with_kg
  model_reader :type
  
  def with_kg(weight_without_kg)
    "#{weight_without_kg} kg"
  end
  
end