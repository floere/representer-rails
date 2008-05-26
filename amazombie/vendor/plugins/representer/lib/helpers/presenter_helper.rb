module PresenterHelper
  
  class MissingPresenterError < RuntimeError; end
  class NotAPresenterError < RuntimeError; end
  
  # Should return a hash in the form of:
  # { SomeModules::ModelClass => SomeModules::PresenterClass }
  #
  # Normally, the default convention is fine, but sometimes you might want to have
  # a specific presenter mapping: This is the place to override it.
  #
  def specific_mapping
    # your hash of specific model-to-presenter class mappings
    {}
  end
  
  # Construct a presenter for a collection.
  #
  def collection_presenter_for(pagination_array, context=self)
    Presenters::Collection.new(pagination_array, context)
  end
  
  # Create a new presenter instance for the given model instance
  # with the given arguments.
  #
  # Note: Presenters are usually from class Presenters::<ModelClassName>.
  # (As returned by default_presenter_class_for)
  # Override specific_mapping if you'd like to install your own.
  # OR: Override default_presenter_class_for(model) if
  # you'd like to change the default.
  #
  def presenter_for(model, context = self)
    begin
      # Is there a specific mapping?
      presenter_class = specific_mapping[model.class]
      
      # If not, get the default mapping.
      unless presenter_class
        presenter_class = default_presenter_class_for(model)
      end
      
      unless presenter_class < Presenters::Base
        raise NotAPresenterError.new("#{presenter_class} is not a presenter.") 
      end
      
      # And create a presenter for the model.
      presenter_class.new(model, context)
    rescue NameError => e
      raise MissingPresenterError.new("No presenter for #{model.class}.")
    end
  end
  
  # Returns the default presenter class for the given model.
  #
  # Default class name is:
  # Presenters::<ModelClassName>
  #
  def default_presenter_class_for(model)
    "Presenters::#{model.class.name}".constantize
  end
end
