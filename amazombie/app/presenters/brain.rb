class Presenters::Brain < Presenters::Project
  model_reader :weight, :filter_through => :weight_conversion # filter example
  
  def weight_conversion(w)
    # you could convert the weight depending, on the current user
    #   convert_weight w, current_user
    # (use stones, pounds and ounces for those over there).
    "#{w} g"
  end
  
  def description
    model.description +
      weight + 
      'This brain is organicly grown by' +
      former_host
  end
  
  def header
    former_host "'s tasty Brain"
  end
end
