module PresenterHelper
  
  # Should return a hash in the form of:
  # { SomeModules::ModelClass => SomeModules::PresenterClass }
  #
  # Normally, the default convention is fine, but sometimes you might want to have
  # a specific presenter mapping: This is the place to override it.
  #
  def specific_mapping
    # your hash of specific model-to-presenter class mappings
  end
  
  # Construct a presenter for a collection.
  #
  def collection_presenter_for(pagination_array, context=self)
    Presenters::Collection.new(pagination_array, context)
  end
  
  # TODO Comment
  #
  def presenter_for(model, context = self)
    begin
      # Is there a specific mapping?
      presenter_class = (specific_mapping || {})[model.class]
      
      # If not, get the default mapping.
      unless presenter_class
        presenter_class = default_presenter_class_for(model)
      end
      
      # And create a presenter for the model.
      # TODO controller_from remove ok?
      presenter_class.new(model, context) #controller_from(context))
    rescue NameError => e
      raise "No presenter for #{model.class}."
    end
  end
  
  # TODO Comment
  #
  def default_presenter_class_for(model)
    "Presenters::#{model.class.name}".constantize
  end

  # Extracts a controller given an instance variable that might either be a controller itself or a view. 
  #
  # TODO remove?
  #
  # def controller_from(obj)
  #   if obj.respond_to?(:controller)
  #     obj.controller
  #   else
  #     obj
  #   end
  # end
end
