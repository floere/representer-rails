require File.dirname(__FILE__) + '/../spec_helper'

describe Presenters::Base do
  
  describe ".presenter_path" do
    it "should call underscore on its name" do
      name_mock = flexmock(:name)
      flexmock(Presenters::Base).should_receive(:name).once.and_return(name_mock)
      
      name_mock.should_receive(:underscore).once.and_return 'underscored_name'
      Presenters::Base.presenter_path.should == 'underscored_name'
    end
  end
  
  
  
  describe "#render_as" do
    it "should pass through the parameters" do
      
    end
  end
  
end