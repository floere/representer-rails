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
  
  describe "#to_param" do
    it "should delegate to the model" do
      model_mock = flexmock(:model)
      presenter = Presenters::Base.new(model_mock, nil)
      
      model_mock.should_receive(:to_param).once
      presenter.to_param
    end
  end
  
  describe "#render_as" do
    it "should pass through the parameters" do
      
    end
  end
  
end