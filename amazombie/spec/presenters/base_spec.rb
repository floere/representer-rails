require File.dirname(__FILE__) + '/../spec_helper'

describe Presenters::Base do
  
  describe "readers" do
    describe "model" do
      before(:each) do
        @model_mock = flexmock(:model)
        @presenter = Presenters::Base.new(@model_mock, nil)
      end
      it "should have a reader" do
        @presenter.model.should == @model_mock
      end
    end
    describe "context" do
      before(:each) do
        @context_mock = flexmock(:context)
        @presenter = Presenters::Base.new(nil, @context_mock)
      end
      it "should have a reader" do
        @presenter.context.should == @context_mock
      end
    end
  end
  
  class ModelReaderModel < Struct.new(:some_model_value); end
  describe ".model_reader" do
    before(:each) do
      @model = ModelReaderModel.new
      @presenter = Presenters::Base.new(@model, nil)
      class << @presenter
        def a(s); s << 'a' end
        def b(s); s << 'b' end
      end
    end
    it "should call filters in a given pattern" do
      @model.some_model_value = 's'
      @presenter.class.model_reader :some_model_value, :filter_through => [:a, :b, :a, :a]
    
      @presenter.some_model_value.should == 'sabaa'
    end
    it "should pass through the model value if no filters are installed" do
      @model.some_model_value = :some_model_value
      @presenter.class.model_reader :some_model_value
      
      @presenter.some_model_value.should == :some_model_value
    end
  end
  
  describe ".master_helper_module" do
    before(:each) do
      class Presenters::SpecificMasterHelperModule < Presenters::Base; end
    end
    it "should be a class specific inheritable accessor" do
      Presenters::SpecificMasterHelperModule.master_helper_module = :some_value
      Presenters::SpecificMasterHelperModule.master_helper_module.should == :some_value
    end
    it "should be an instance of Module on Base" do
      Presenters::Base.master_helper_module.should be_instance_of(Module)
    end
  end
  
  describe ".context_method_delegations" do
    before(:each) do
      class Presenters::ContextMethodDelegating < Presenters::Base; end
      class Presenters::AlsoContextMethodDelegating < Presenters::Base; end
      
      Presenters::Base.context_method_delegations = []
      
      Presenters::ContextMethodDelegating.context_method_delegations = :one_value
      Presenters::AlsoContextMethodDelegating.context_method_delegations = :other_value
    end
    it "should be a class specific inheritable accessor" do
      Presenters::ContextMethodDelegating.context_method_delegations.should == :one_value
    end
    it "should not set specific context_method_delegations on Base" do
      Presenters::Base.context_method_delegations.should == []
    end
  end
  
  describe ".context_method" do
    before(:each) do
      Presenters::Base.context_method_delegations = []
    end
    it "should add the method to the method delegations" do
      flexmock(Presenters::Base).should_receive(:context_method_delegations=).once.with [:method1, :method2]
      Presenters::Base.context_method :method1, :method2
    end
    it "should set up delegate calls to the context" do
      flexmock(Presenters::Base).should_receive(:delegate).once.with(:method1, :to => :context)
      flexmock(Presenters::Base).should_receive(:delegate).once.with(:method2, :to => :context)
      Presenters::Base.context_method :method1, :method2
    end
  end
  
  describe ".helper" do
    it "should include the helper" do
      helper_module = Module.new
      flexmock(Presenters::Base).should_receive(:include).once.with helper_module
      
      Presenters::Base.helper helper_module
    end
    it "should include the helper in the master helper module" do
      master_helper_module_mock = flexmock(:master_helper_module)
      flexmock(Presenters::Base).should_receive(:master_helper_module).and_return master_helper_module_mock
      
      helper_module = Module.new
      master_helper_module_mock.should_receive(:include).once.with helper_module
      
      Presenters::Base.helper helper_module
    end
  end
  
  describe ".presenter_path" do
    it "should call underscore on its name" do
      name_mock = flexmock(:name)
      flexmock(Presenters::Base).should_receive(:name).once.and_return(name_mock)
      
      name_mock.should_receive(:underscore).once.and_return 'underscored_name'
      Presenters::Base.presenter_path.should == 'underscored_name'
    end
  end
  
  describe "#logger" do
    it "should delegate to the context" do
      context_mock = flexmock(:context)
      presenter = Presenters::Base.new(nil, context_mock)
      
      context_mock.should_receive(:logger).once
      presenter.logger
    end
  end
  
  describe ".default_format" do
    it "should return :html" do
      Presenters::Base.default_format.should == :html
    end
  end
  describe "#default_format" do
    it "should delegate to the class" do
      flexmock(Presenters::Base).should_receive(:default_format).once
      Presenters::Base.new(nil, nil).default_format
    end
  end
  
  describe "#render_as" do
    before(:each) do
      @model_mock = flexmock(:model)
      @context_mock = flexmock(:context)
      @presenter = Presenters::Base.new(@model_mock, @context_mock)
    end
    it "should call all the necessary methods" do
      view_name = flexmock(:view_name)
      
      flexmock(@presenter).should_receive(:load_instance_variables_for_rendering).once.with view_name
      
      presenter_instance_variables_mock = flexmock(:presenter_instance_variables_mock)
      flexmock(@presenter).should_receive(:collect_instance_variables_for_view).once.and_return presenter_instance_variables_mock
      
      view_class_mock = flexmock(:view_class)
      flexmock(@presenter).should_receive(:initialize_view_class).once.and_return view_class_mock
      
      view_instance_mock = flexmock(:view_instance)
      flexmock(@presenter).should_receive(:view_instance_from).once.with(view_class_mock, presenter_instance_variables_mock).and_return view_instance_mock
      
      flexmock(@presenter).should_receive(:default_format).once.and_return :html
      view_instance_mock.should_receive(:template_format=).once.with :html
      
      path_mock = flexmock(:path)
      flexmock(@presenter).should_receive(:template_path).once.with(view_name).and_return path_mock
      
      view_instance_mock.should_receive(:render_file).once.with(path_mock, true)
      
      @presenter.render_as(view_name)
    end
  end
  
  describe "with mocked Presenter" do
    attr_reader :model_mock, :context_mock, :presenter
    before(:each) do
      @model_mock = flexmock(:model)
      @context_mock = flexmock(:context)
      @presenter = Presenters::Base.new(model_mock, context_mock)
    end
    describe "#presenter_template_path" do
      describe "absolute path given" do
        it "should use it as given" do
          presenter.template_path('some/path/to/template').should == 'some/path/to/template'
        end
      end
      describe "with just the template name" do
        it "should prepend the presenter path" do
          flexmock(Presenters::Base).should_receive(:presenter_path).and_return('some/presenter/path/to')
          
          presenter.template_path('template').should == 'some/presenter/path/to/template'
        end
      end
    end
    describe "#initialize_view_class" do
      it "should get a new anonymous view class" do
        anonymous_view_class = Class.new(ActionView::Base)
        flexmock(Class).should_receive(:new).once.with(ActionView::Base).and_return anonymous_view_class
        
        presenter.initialize_view_class
      end
      it "should include the master helper module in the view class" do
        anonymous_view_class = flexmock(:anonymous_view_class)
        anonymous_view_class.should_receive(:delegate)
        flexmock(Class).should_receive(:new).once.with(ActionView::Base).and_return anonymous_view_class
        
        anonymous_view_class.should_receive(:include).once.with(presenter.master_helper_module)
        presenter.initialize_view_class
      end
      
      # TODO Or should it??? Possibly not. Maybe render with @context.instance_eval?
      #
      it "should install all the context delegates in the view" do
        anonymous_view_class = flexmock(:anonymous_view_class)
        anonymous_view_class.should_receive(:include)
        flexmock(Class).should_receive(:new).once.with(ActionView::Base).and_return anonymous_view_class
        
        flexmock(presenter).should_receive(:delegate_methods_to_context_in).once.with(anonymous_view_class)
        presenter.initialize_view_class
      end
      
      it "should return the created view class" do
        anonymous_view_class = flexmock(:anonymous_view_class)
        anonymous_view_class.should_receive(:include)
        flexmock(Class).should_receive(:new).once.with(ActionView::Base).and_return anonymous_view_class
        
        flexmock(presenter).should_receive(:delegate_methods_to_context_in)
        
        presenter.initialize_view_class.should == anonymous_view_class
      end
    end
    describe "#collect_instance_variables_for_view" do
      it "should hand the right variables to the view" do
        presenter.collect_instance_variables_for_view.should == {
          :model => model_mock,
          :context => context_mock,
          :controller => context_mock,
          :presenter => presenter
        }
      end
    end
  end
  
  describe "#load_instance_variables_for_rendering" do
    it "should not call the load method on self if there is none" do
      presenter = Presenters::Base.new(nil, nil)
      
      presenter_mock = flexmock(presenter)
      presenter_mock.should_receive(:respond_to?).with(/load_some_view_name$/).and_return false # with(:load_some_view_name) does not work
      presenter_mock.should_receive(:load_some_view_name).never
      
      presenter.load_instance_variables_for_rendering 'some_view_name'
    end
    it "should call the load method on self if there is one" do
      presenter = Presenters::Base.new(nil, nil)
      flexmock(presenter).should_receive(:load_some_view_name).once
      
      presenter.load_instance_variables_for_rendering 'some_view_name'
    end
  end
  
  describe "#view_instance_from" do
    it "should call new on the given view class" do
      context_mock = flexmock(:context)
      presenter = Presenters::Base.new(nil, context_mock)
      
      view_class_mock = flexmock(:view_class)
      presenter_instance_variables_mock = flexmock(:presenter_instance_variables_mock)
      
      view_paths_mock = flexmock(:view_paths)
      context_mock.should_receive(:view_paths).and_return view_paths_mock
      
      view_class_mock.should_receive(:new).once.with(view_paths_mock, presenter_instance_variables_mock, context_mock)
      presenter.view_instance_from(view_class_mock, presenter_instance_variables_mock)
    end
  end
  
end