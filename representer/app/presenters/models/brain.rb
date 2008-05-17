class Presenters::Models::Brain < Presenters::Project
  
  model_reader :weight, :filter_through => :with_kg
  model_reader :type #, :filter_through => :truncate_10
  
  def with_kg(weight_without_kg)
    "#{weight_without_kg} kg"
  end
  
  # def truncate_10(text)
  #   truncate(text, 10)
  # end
  
end