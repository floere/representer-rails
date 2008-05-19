class Presenters::Base
  # TODO remove?
  include ActionController::UrlWriter

  # Every presenter needs a model and a context.
  attr_reader :model, :context

  # A module that will collect all helpers that need to be made available to the view. 
  class_inheritable_accessor :master_helper_module
  self.master_helper_module = Module.new

  # All the methods that are delegated from the presenter or its view to the context.
  class_inheritable_accessor :context_method_delegations
  self.context_method_delegations = []
  
  class << self

    # Define a reader for a model attribute. Acts as a filtered delegation to the model. 
    #
    # You may specify a :filter_through option that is either a symbol or an array of symbols. The return value
    # from the model will be filtered through the functions (arity 1) and only then passed back 
    # to the receiver. 
    #
    # Example: 
    #
    #   model_reader :foobar                                        # same as delegate :foobar, :to => :model
    #   model_reader :foobar, :filter_through => :h                 # html escape foobar 
    #   model_reader :foobar, :filter_through => [:textilize, :h]   # first textilize, then html escape
    # 
    # TODO think about this one
    #
    def model_reader(*args)
      args = args.dup
      opts = args.pop if args.last.kind_of?(Hash)
      
      fields = args.flatten
      filters = opts.nil? ? [] : [*(opts[:filter_through])].reverse
      
      fields.each do |field|
        reader = "def #{field}; 
                  #{filters.join('(').strip}(model.#{field})#{')' * (filters.size - 1) unless filters.empty?}; 
                  end"
        class_eval(reader)
      end
    end
    
    # Make a helper available to the current presenter, its subclasses and the presenter's views. 
    #
    def helper(helper)
      include helper
      master_helper_module.send(:include, helper)
    end

    # Delegates method calls to the context.
    #
    # Example: 
    #   context_method :current_user
    #
    def context_method(*methods)
      self.context_method_delegations += methods
      
      methods.each do |method|
        delegate method, :to => :context
      end
    end
    
    # Returns the path from the presenter_view_paths to the actual templates.
    # e.g. "presenters/models/book"
    #
    def presenter_path
      name.underscore
    end
  end  # class << self
  
  # Create a presenter. To create a presenter, you need to have a model (to present) and a context.
  # The only thing used from the +context+ is its capability to answer to certain basic messages
  # like #url_for.
  # 
  def initialize(model, context)
    @model, @context = model, context
  end

  # Make #logger available in presenters. 
  #
  context_method :logger
  
  # Delegate #to_param to the model by default.
  #
  # TODO or not? Too Active Record specific? Should I do a Presenters::AR Subclass?
  #
  model_reader :to_param

  # Returns the path from the presenter_view_paths to the actual templates. 
  #
  # def presenter_path
  #   self.class.presenter_path
  # end

  # Returns the root of this presenter's views.
  #
  # def presenter_view_paths
  #   File.join(RAILS_ROOT, 'app/views')
  # end

  # This class is needed so that we can fake out certain details of the context (often a controller).
  # For example, we need to prevent prepending the path of each rendered partial with the controller
  # name - we want partials to be searched for in template root itself. So we redefine controller_path
  # here, while keeping everything else.
  #
  # This is basically a proxy for the controller.
  #
  # TODO still needed, is context enough?
  #
  # class RenderingContext
  #   def initialize(presenter, context)
  #     @presenter, @context = presenter, context
  #   end
  #   
  #   def class
  #     RenderingContextClass.new(@presenter)
  #   end
  #   
  #   def method_missing(*args, &block)
  #     @context.send(*args, &block)
  #   end
  #   # def respond_to?(sym)
  #   #   self.respond_to?(sym) || @context.respond_to?(sym)
  #   # end
  # end
  # class RenderingContextClass
  #   def initialize(presenter)
  #     @presenter = presenter
  #   end
  #   def controller_path
  #     @presenter.presenter_path
  #   end
  # end
  
  # Renders the given view in the presenter's view root in the format given.
  #
  # Example:
  #   app/views/presenters/this/presenter/template.html.haml
  #   app/views/presenters/this/presenter/template.text.erb
  #
  # Calling presenter.render_as('template', :html) will render the first
  # template, calling presenter.render_as('template', :text) will render
  # the second.
  # 
  def render_as(view, format = :html)
    # load_variables_for_template_name
    load_instance_variables_for_rendering view
    
    # Copy instance variables from the presenter to a hash to
    # expose these to the view.
    presenter_instance_variables = load_instance_variables
    
    # Initialize a new anonymous view class.
    view_class = initialize_view_class
    
    # Get a view instance from the view class.
    view_instance = view_instance_from view_class, presenter_instance_variables
    
    # Set the format to render in, e.g. text, html
    view_instance.template_format = format
    
    # Finally, render
    view_instance.render_file(presenter_template_path(view), true)
  end
  
  # TODO Possibly not so clever loading them straight into the
  # presenter if it is rendered multiple times.
  #
  def load_instance_variables_for_rendering(view)
    load_method_name = "load_#{view}".to_sym
    self.send(load_method_name) if self.respond_to? load_method_name
  end
  
  def load_instance_variables
    instance_variables.inject(
      { :presenter => self, :controller => @context } # TODO @context.controller?
    ) do |vars, var|
      next vars if %w{@controller}.include?(var)
      vars[var[1..-1].to_sym] = instance_variable_get(var)
      vars
    end
  end
  
  def initialize_view_class
    # Get anonymous view class.
    view_klass = Class.new(ActionView::Base)
    
    # Include the master helper module.
    view_klass.send(:include, master_helper_module)
    
    # Install context delegations.
    context_method_delegations.each do |context_method|
      view_klass.delegate context_method, :to => :context
    end
  end
  
  def view_instance_from(view_class, presenter_instance_variables)
    view_instance = view_class.new(
      context.view_paths,
      presenter_instance_variables,
      context #RenderingContext.new(self, context) # probably needed if rendering in the controller
    )
  end
  
  # module ViewExtension
  #   # We don't allow paths with extension - and we don't want to cut off the
  #   # :format extension we append, so we just avoid touching the path. This 
  #   # overrides the version in ActionView::Base
  #   #
  #   # def path_and_extension(path)
  #   #   [path, nil]
  #   # end
  #   
  #   # A path generator is an interface that the presenter implements itself. It
  #   # allows the presenter to help out with path generation in ActionView::Base
  #   #
  #   def path_generator=(value)
  #     @path_generator = value
  #   end
  #   
  #   # 
  #   def full_template_path(template_path, extension)
  #     @path_generator.generate_path(template_path, extension)
  #   end
  # end
  # def generate_path(template_path, extension)
  #   generated_path = presenter_template(template_path, extension)
  #   generated_path
  # end
  
  # Returns the root of this presenters views with the template name appended.
  # e.g. 'presenters/some/specific/path/to/template'
  #
  def presenter_template_path(name)
    name = name.to_s
    if name.include?('/')    # Specific path like 'presenters/somethingorother/foo.haml' given.
      name
    else
      File.join(self.class.presenter_path, name)
    end
  end
  
  # Renders a template.
  #
  # In the template, you can access all instance variables of the presenter as
  # well as the @presenter, @controller instance variable.
  #
  # Options are: 
  #
  #   :format         Whatever you use as a format here will define which template is rendered.
  #
  # def render_template(template, format)
    
    # Copy instance variables from the presenter to a hash to
    # expose these to the view
    # presenter_instance_variables = instance_variables.inject(
    #   { :presenter => self, :controller => @context } # TODO @context.controller?
    # ) do |vars, var|
    #   next vars if %w{@controller}.include?(var)
    #   vars[var[1..-1].to_sym] = instance_variable_get(var)
    #   vars
    # end
    
    # Create a new anonymous view class.
    # view_klass = Class.new(ActionView::Base)
    # view_klass.send(:include, master_helper_module)
    
    # view_klass.send(:include, ViewExtension)
    
    # # Install context delegations.
    # context_method_delegations.each do |context_method|
    #   view_klass.delegate context_method, :to => :context
    # end
    
    # view_instance = view_klass.new(
    #   context.view_paths,
    #   presenter_instance_variables,
    #   context #RenderingContext.new(self, context) # probably needed if rendering in the controller
    # )
    
    # Set the format to render in, e.g. text, html
    # view_instance.template_format = format
    
    # Render the template.
    # view_instance.render_file(presenter_template_path(template), true)
  # end
  
  # private
  # 
  #   # Remove the last element from args, if it's a Hash and return args and the Hash.
  #   #
  #   def extract_options(args)
  #     opts = {}
  #   
  #     if args.last.is_a?(Hash)
  #       opts = args.pop
  #     end
  #   
  #     return [args, opts]
  #   end
  
end