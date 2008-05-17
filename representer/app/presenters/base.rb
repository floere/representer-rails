class Presenters::Base
  include ActionController::UrlWriter

  # Every presenter needs a model
  attr_accessor :model, :context

  # A module that will collect all helpers that need to be made available to the view. 
  class_inheritable_accessor :master_helper_module
  self.master_helper_module = Module.new

  # All the methods that are delegated from the presenter or its view to the context.
  class_inheritable_accessor :context_method_delegations
  self.context_method_delegations = []
    
  # Class methods: model_reader, etc..
  #
  class << self

    # Define a reader for a model attribute. This is like a delegation to the model#attr. 
    #
    # You may specify a :filter_through option that is either a symbol or an array of symbols. Return value
    # from the model attribute will be filtered through the functions (arity 1) and only then passed back 
    # to the receiver. 
    #
    # Example: 
    #
    #   model_reader :foobar                                        # like delegate :foobar, :to => :model
    #   model_reader :foobar, :filter_through => :h                 # html escape foobar 
    #   model_reader :foobar, :filter_through => [:textilize, :h]   # first textilize, then html escape
    #
    # def model_reader(*args)
    #   args = args.dup         # let's not modify args array
    #   
    #   opts = {}
    #   opts = args.pop if args.last.kind_of?( Hash )
    #         
    #   args.each do |field|
    #     delegate field, :to => :model
    #     
    #     # Method chain a filter to the method we just created.
    #     if opts.has_key? :filter_through
    #       filter_chain=[*(opts[:filter_through])].reverse
    #       module_eval(<<-EOS, "(__PRESENTER FILTER__)", 1)
    #         def #{field}_with_filter(*args, &block)
    #           #{filter_chain.join('(')}(#{field}_without_filter(*args, &block))#{[')']*(filter_chain.size-1)}
    #         end
    #       EOS
    #       
    #       alias_method_chain field, :filter
    #     end
    #   end
    # end   # def model_reader
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
    
    # Make a helper available for the current presenter and all its subclasses. The views will also have it. 
    #
    def helper(helper)
      include helper
      master_helper_module.send(:include, helper)
    end

    # Allow calling of certain context methods in both the presenter and the view. 
    #
    # Example: 
    #   context_method :current_user
    #
    def context_method(*methods)
      self.context_method_delegations += methods
      
      methods.each do |cmethod|
        delegate cmethod, :to => :context
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

  # You can use #logger in your presenters. 
  #
  # TODO remove since delegated?
  def logger
    RAILS_DEFAULT_LOGGER
  end

  # Returns the path from the presenter_view_paths to the actual templates. 
  #
  def presenter_path
    self.class.presenter_path
  end

  # Returns the root of this presenters views
  #
  # def presenter_view_paths
  #   File.join(RAILS_ROOT, 'app/views')
  # end

  # Returns the root of this presenters views
  #
  def presenter_template(name)
    if name.index('/')    # presenters/somethingorother/_foo.haml
      name
    else
      File.join(presenter_path, name)
    end
  end

  # This class is needed so that we can fake out certain details of the context (often a controller).
  # For example, we need to prevent prepending the path of each rendered partial with the controller
  # name - we want partials to be searched for in template root itself. So we redefine controller_path
  # here, while keeping everything else.
  #
  # This is basically a proxy for the controller.
  #
  class RenderingContext
    def initialize(presenter, context)
      @presenter, @context = presenter, context
    end
    
    def class
      RenderingContextClass.new(@presenter)
    end
    
    def method_missing(*args, &block)
      @context.send(*args, &block)
    end
    # def respond_to?(sym)
    #   self.respond_to?(sym) || @context.respond_to?(sym)
    # end
  end
  class RenderingContextClass
    def initialize(presenter)
      @presenter = presenter
    end
    def controller_path
      @presenter.presenter_path
    end
  end

  # Render a presenter view. 
  #
  # Rendering :ACTION, the presenter method render_ACTION will be called to
  # initialize rendering. Then the partial _ACTION will be rendered. The
  # partial has the following variables at its disposition (on top of those
  # set by render_ACTION): 
  #
  #   @model            The model that is being presented. 
  #   @presenter        The presenter itself
  #  
  # Your render_ACTION method can have any number of arguments. Using
  # Presenter#render(view, ...), you can pass arguments through to your
  # render_ACTION method.
  #
  # def render_as(view, *args)
  #   render_action_name = "render_#{view}"
  #   
  #   args, opts = extract_options(args)
  #   
  #   self.send(render_action_name, *args)
  #   render_template view, opts
  # end
  
  def render_as(view, format)
    # load_variables_for_template_name
    load_method_name = "load_#{view}".to_sym
    self.send(load_method_name) if self.respond_to? load_method_name
    
    template_format = format
    
    render_template view
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
  #     p [:debug, :full_template_path_called]
  #     @path_generator.generate_path(template_path, extension)
  #   end
  # end
  # def generate_path(template_path, extension)
  #   generated_path = presenter_template(template_path, extension)
  #   p [:debug, :generated_path, generated_path]
  #   generated_path
  # end

  # TODO should we override this?
  #
  # # symbolized version of the :format parameter of the request, or :html by default.
  # def template_format
  #   return @template_format if @template_format
  #   format = context.respond_to?(:request) && context.request.parameters[:format]
  #   @template_format = format.blank? ? :html : format.to_sym
  # end
  # def template_format=(format)
  #   @template_format = format
  # end
  
  # Renders a template.
  #
  # In the template, you can access all instance variables of the presenter as
  # well as the @presenter instance variable.
  #
  # Options are: 
  #
  #   :format         Whatever you use as a format here will be appended to the template name: 
  #                   :html gives you template.html
  #
  def render_template(template)
    # @presenter = self
  
    # copy instance variables from the presenter to a hash
    presenter_instance_variables = instance_variables.inject(
      { :presenter => self, :controller => @context }
    ) do |vars, var|
      next vars if %w{@controller}.include?(var)
      vars[var[1..-1].to_sym] = instance_variable_get(var)
      vars
    end
        
    view_klass = Class.new(ActionView::Base)
    view_klass.send(:include, master_helper_module)
    
    # view_klass.send(:include, ViewExtension)
    
    context_method_delegations.each do |controller_method|
      view_klass.delegate controller_method, :to => :controller
    end
    
    view_instance = view_klass.new(
      context.view_paths,
      presenter_instance_variables,
      RenderingContext.new(self, context)
    )
    
    # view_instance.path_generator = self
    
    # template_name = [template, 'html', 'haml'].compact.join('.')
    template_name = template.to_s
    # view_instance.render_file(template_name, true)
    # replaced with
    view_instance.render_file(presenter_template(template_name), true)
  end
  
  delegate :to_param,           :to => :model
  
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