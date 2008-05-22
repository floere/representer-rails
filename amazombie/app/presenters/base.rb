module Presenters
  
  # This module we include if we are given a controller.
  #
  module ControllerContextMethods
    def create_view_class
      @controller.class.template_class
    end
    # def default_format
    #   # TODO
    #   # 
    #   #@context.template_format
    # end
    def view_paths
      @controller.view_paths
    end
  end
  
  # This module we include if we are given a view.
  #
  module ViewContextMethods
    def create_view_class
      @view.class
    end
    # def default_format
    #   @view.template_format
    # end
    def view_paths
      @view.view_paths
    end
  end
  
  class Base
    attr_reader :model, :controller

    # A module that will collect all helpers that need to be made available to the view. 
    class_inheritable_accessor :master_helper_module
    self.master_helper_module = Module.new

    # All the methods that are delegated from the presenter or its view to the context.
    class_inheritable_accessor :controller_method_delegations
    self.controller_method_delegations = []
  
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
      # Same as in Controller::Base.
      #
      def helper(helper)
        include helper
        master_helper_module.send(:include, helper)
      end
    
      # Delegates method calls to the controller.
      #
      # Example: 
      #   controller_method :current_user
      #
      def controller_method(*methods)
        self.controller_method_delegations += methods
      
        methods.each do |method|
          delegate method, :to => :controller
          private method # TODO really necessary?
        end
      end
    
      # Returns the path from the presenter_view_paths to the actual templates.
      # e.g. "presenters/models/book"
      #
      def presenter_path
        name.underscore
      end
    end # class << self
  
    # Create a presenter. To create a presenter, you need to have a model (to present) and a context.
    # The only thing used from the +context+ is its capability to answer to certain basic messages
    # like #url_for.
    # 
    def initialize(model, context)
      @model, @context = model, context # @context still needed
      if @context.respond_to?(:controller)
        class << self
          include ViewContextMethods
        end
        @controller = @context.controller
        @view = @context
      else
        class << self
          include ControllerContextMethods
        end
        @controller = @context
        @view = nil
      end
    end

    # TODO Make #helper delegates on created view!!!

    # Make #logger available in presenters. 
    #
    controller_method :logger
  
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
    def render_as(view, format = nil)
      # Load instance variables from the presenter load method.
      # load_instance_variables_for_rendering view
    
      # Copy instance variables from the presenter to a hash to
      # expose these to the view.
      presenter_instance_variables = collect_instance_variables_for_view
    
      # Initialize a new anonymous view class.
      view_class = set_up_view_class
    
      # Get a view instance from the view class.
      view_instance = view_instance_from view_class, presenter_instance_variables
    
      # Set the format to render in, e.g. :text, :html
      view_instance.template_format = format if format
    
      # Finally, render
      view_instance.render_file(template_path(view), true)
    end
  
    # TODO Possibly not so clever loading them straight into the
    # presenter if it is rendered multiple times.
    #
    # def load_instance_variables_for_rendering(view)
    #   load_method_name = "load_#{view}".to_sym
    #   self.send(load_method_name) if self.respond_to? load_method_name
    # end
  
    # TODO Decouple from method above. (Using the bucket technique)
    #
    def collect_instance_variables_for_view
      instance_variables.inject(
        { :presenter => self, :model => @model, :controller => @controller }
      ) do |vars, var|
        vars[var[1..-1].to_sym] = instance_variable_get(var)
        vars
      end # TODO use the bucket technique
    end
  
    def set_up_view_class
      # Get anonymous view class.
      view_class = create_view_class
    
      # Include the master helper module.
      view_class.send(:include, master_helper_module)
    
      view_class
    end
  
    def view_instance_from(view_class, presenter_instance_variables)
      view_class.new(
        view_paths,
        presenter_instance_variables,
        @controller #RenderingContext.new(self, context) # probably needed if rendering in the controller
      )
    end
  
    # Returns the root of this presenters views with the template name appended.
    # e.g. 'presenters/some/specific/path/to/template'
    #
    def template_path(name)
      name = name.to_s
      if name.include?('/')    # Specific path like 'presenters/somethingorother/foo.haml' given.
        name
      else
        File.join(self.class.presenter_path, name)
      end
    end
  
  end
end