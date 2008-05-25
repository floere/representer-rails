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
    describe "controller" do
      before(:each) do
        @context_mock = flexmock(:controller)
        @presenter = Presenters::Base.new(nil, @context_mock)
      end
      it "should have a reader" do
        @presenter.controller.should == @context_mock
      end
    end
  end
  
  describe "context recognition" do
    describe "context is a view" do
      before(:each) do
        @view_mock = flexmock(:view)
        @view_mock.should_receive(:controller).and_return 'controller'
        @presenter = Presenters::Base.new(nil, @view_mock)
      end
      it "should get the controller from the view" do
        @presenter.controller.should == 'controller'
      end
    end
    describe "context is a controller" do
      before(:each) do
        @controller_mock = flexmock(:controller)
        @presenter = Presenters::Base.new(nil, @controller_mock)
      end
      it "should just use it for the controller" do
        @presenter.controller.should == @controller_mock
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
  
  describe ".controller_method" do
    it "should set up delegate calls to the controller" do
      flexmock(Presenters::Base).should_receive(:private)
      flexmock(Presenters::Base).should_receive(:delegate).once.with(:method1, :to => :controller)
      flexmock(Presenters::Base).should_receive(:delegate).once.with(:method2, :to => :controller)
      
      Presenters::Base.controller_method :method1, :method2
    end
    it "should make the delegate methods private" do
      flexmock(Presenters::Base).should_receive(:delegate)
      flexmock(Presenters::Base).should_receive(:private).once.with(:method1)
      flexmock(Presenters::Base).should_receive(:private).once.with(:method2)
      
      Presenters::Base.controller_method :method1, :method2
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
    it "should delegate to the controller" do
      controller_mock = flexmock(:controller)
      presenter = Presenters::Base.new(nil, controller_mock)
      
      controller_mock.should_receive(:logger).once
      presenter.instance_eval do
        # can be called in the presenter instance
        logger
      end
    end
  end
  
  describe "#render_as" do
    before(:each) do
      model_mock = flexmock(:model)
      context_mock = flexmock(:context)
      @presenter = Presenters::Base.new(model_mock, context_mock)
      
      @view_name = flexmock(:view_name)
      view_class_mock = flexmock(:view_class)
      @view_instance_mock = flexmock(:view_instance)
      
      flexmock(@presenter).should_receive(:view_instance_from).once.with(view_class_mock).and_return @view_instance_mock
      
      flexmock(@presenter).should_receive(:view_class).once.and_return(view_class_mock)
      
      path_mock = flexmock(:path)
      flexmock(@presenter).should_receive(:template_path).once.with(@view_name).and_return path_mock
      
      @view_instance_mock.should_receive(:render_file).once.with(path_mock, true)
    end
    it "should not call template_format=" do
      @view_instance_mock.should_receive(:template_format=).never
      
      @presenter.render_as(@view_name)
    end
    it "should call template_format=" do
      @view_instance_mock.should_receive(:template_format=).once.with(:some_format)
      
      @presenter.render_as(@view_name, :some_format)
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
    describe "#instance_variables_for_view" do
      it "should hand the right variables to the view" do
        presenter.instance_variables_for_view.should == {
          :model => model_mock,
          :controller => context_mock,
          :presenter => presenter
        }
      end
    end
    
    describe "#view_class" do
      before(:each) do
        @view_class_mock = flexmock(:view_class)
        @context_mock.should_receive('class.template_class').and_return @view_class_mock
      end
      it "should include the master helper module in the view class" do
        master_helper_module_mock = flexmock(:master_helper_module)
        flexmock(presenter).should_receive(:master_helper_module).and_return master_helper_module_mock
        @view_class_mock.should_receive(:include).with(master_helper_module_mock)

        presenter.view_class
      end
      it "should return the view class" do
        flexmock(presenter).should_receive(:master_helper_module)
        @view_class_mock.should_receive(:include)
        
        presenter.view_class == @view_class_mock
      end
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
      presenter.view_instance_from(view_class_mock)
    end
  end
  
end