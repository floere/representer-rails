require File.dirname(__FILE__) + '/../spec_helper'

describe PresenterHelper do
  
  describe "collection_presenter_for" do
    it "should return kind of a Presenters::Collection" do
      collection_presenter_for([]).should be_kind_of(Presenters::Collection)
    end
    it "should pass any parameters directly through" do
      collection_mock = flexmock(:collection)
      context_mock = flexmock(:context)
      flexmock(Presenters::Collection).should_receive(:new).with(collection_mock, context_mock).once
      collection_presenter_for(collection_mock, context_mock)
    end
  end
  
  describe "presenter_for" do
    it "should just pass the params through to the presenter" do
      model_mock = flexmock(:model)
      context_mock = flexmock(:context)
      
      presenter_class_mock = flexmock(:presenter_class_mock)
      flexmock(self).should_receive(:default_presenter_class_for).and_return presenter_class_mock
      
      presenter_class_mock.should_receive(:new).once.with(model_mock, context_mock)
      
      presenter_for(model_mock, context_mock)
    end
    describe "no specific mapping" do
      before(:each) do
        flexmock(self).should_receive(:specific_mapping).and_return {}
      end
      it "should raise on a non-presenter instance" do
        class SomeNonPresenterClass; end
        class Presenters::SomeNonPresenterClass; end
        lambda {
          presenter_for(SomeNonPresenterClass.new)
        }.should raise_error(PresenterHelper::NotAPresenterError, 'Presenters::SomeNonPresenterClass is not a presenter.')
      end
      it "should raise on an non-mapped model" do
        lambda {
          presenter_for(42)
        }.should raise_error(PresenterHelper::MissingPresenterError, 'No presenter for Fixnum.')
      end
      it "should return a default presenter instance" do
        class SomeModelClass; end
        class Presenters::SomeModelClass < Presenters::Base; end
        presenter_for(SomeModelClass.new).should be_instance_of(Presenters::SomeModelClass)
      end
    end
    describe "with specific mapping" do
      class SomeModelClass; end
      class Presenters::SomeSpecificClass < Presenters::Base; end
      before(:each) do
        flexmock(self).should_receive(:specific_mapping).and_return(
          { SomeModelClass => Presenters::SomeSpecificClass }
        )
      end
      it "should return a specifically mapped presenter instance" do
        presenter_for(SomeModelClass.new).should be_instance_of(Presenters::SomeSpecificClass)
      end
      it "should not call #default_presenter_class_for" do
        flexmock(self).should_receive(:default_presenter_class_for).never
        presenter_for(SomeModelClass.new)
      end
    end
  end
  
  describe "default_presenter_class_for" do
    it "should return a class with Presenters:: prepended" do
      class Gaga; end # The model.
      class Presenters::Gaga < Presenters::Base; end
      default_presenter_class_for(Gaga.new).should == Presenters::Gaga
    end
    it "should raise a NameError if the Presenter class does not exist" do
      class Brrzt; end # Just the model.
      lambda {
        default_presenter_class_for(Brrzt.new)
      }.should raise_error(NameError, "uninitialized constant Presenters::Brrzt")
    end
  end
  
  describe "specific_mapping" do
    it "should return nil by default" do
      specific_mapping.should be_nil
    end
  end
  
end