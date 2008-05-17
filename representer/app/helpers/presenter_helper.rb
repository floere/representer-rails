module PresenterHelper
  
  SPECIFIC_PRESENTER_MAPPING = {}
  
  # REMOVE - TOO SPECIFIC
  # {
  #   Video::MusicVideo => Presenters::Clip::Release,
  #   Video::SpecialFeature => Presenters::Clip::Release,
  #   Video::Ad => Presenters::Clip::Ad,
  #   Video::Jingle => Presenters::Clip::Jingle,
  #   Video::Clip => Presenters::Clip::Clip,
  #   
  #   Contact::Link => Presenters::Profile::Link,
  #   
  #   NilClass =>  Presenters::Nil
  # }
  
  # Construct a presenter for a collection.
  #
  def collection_presenter_for(pagination_array, context=self)
    Presenters::Collection.new(pagination_array, context)
  end
  
  def presenter_for(model, context = self)
    begin
      presenter_class = SPECIFIC_PRESENTER_MAPPING[model.class]
      
      unless presenter_class
        presenter_class = default_presenter_class_for(model)
      end
      
      presenter_class.new(model, controller_from(context))
    rescue NameError => e
      raise "No presenter for #{model.class}."
    end
  end
  
  def default_presenter_class_for(model)
    "Presenters::Models::#{model.class.name}".constantize
  end

  # Return an array of presenters for these events
  #
  def presenters_for_events(events_list, context=self)
    events_list.collect { |event| presenter_for(event, context) }
  end

  # Extracts a controller given an instance variable that might either be a controller itself or a view. 
  #
  def controller_from(obj)
    if obj.respond_to?(:controller)
      obj.controller
    else
      obj
    end
  end
end
