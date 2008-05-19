require File.dirname(__FILE__) + '/../spec_helper'

describe Presenters::Base do
  
  attr_reader :collection_mock, :context_mock, :collection_presenter
  
  before(:each) do
    @collection_mock = flexmock(:collection)
    @context_mock = flexmock(:context)
    @collection_presenter = Presenters::Collection.new(@collection_mock, @context_mock)
  end
  
  describe "list" do
    it "should call render_partial and return the rendered result" do
      flexmock(collection_presenter).should_receive(:render_partial).and_return(:result)
      
      collection_presenter.list.should == :result
    end
    it "should call render_partial with the right parameters" do
      default_options = {
        :collection => collection_mock,
        :context => context_mock,
        :template_name => :list_item,
        :separator => nil
      }
      flexmock(collection_presenter).should_receive(:render_partial).once.with('list', default_options)
      
      collection_presenter.list
    end
    it "should override the default options if specific options are given" do
      specific_options = {
        :collection => :a,
        :context => :b,
        :template_name => :c,
        :separator => :d
      }
      flexmock(collection_presenter).should_receive(:render_partial).once.with('list', specific_options)
      
      collection_presenter.list(specific_options)
    end
  end
  
  describe "collection" do
    it "should call render_partial and return the rendered result" do
      flexmock(collection_presenter).should_receive(:render_partial).and_return(:result)
      
      collection_presenter.collection.should == :result
    end
    it "should call render_partial with the right parameters" do
      default_options = {
        :collection => collection_mock,
        :context => context_mock,
        :template_name => :collection_item,
        :separator => nil
      }
      flexmock(collection_presenter).should_receive(:render_partial).once.with('collection', default_options)
      
      collection_presenter.collection
    end
    it "should override the default options if specific options are given" do
      specific_options = {
        :collection => :a,
        :context => :b,
        :template_name => :c,
        :separator => :d
      }
      flexmock(collection_presenter).should_receive(:render_partial).once.with('collection', specific_options)
      
      collection_presenter.collection(specific_options)
    end
  end
  
  describe "table" do
    it "should call render_partial and return the rendered result" do
      flexmock(collection_presenter).should_receive(:render_partial).and_return(:result)
      
      collection_presenter.table.should == :result
    end
    it "should call render_partial with the right parameters" do
      default_options = {
        :collection => collection_mock,
        :context => context_mock,
        :template_name => :table_row,
        :separator => nil
      }
      flexmock(collection_presenter).should_receive(:render_partial).once.with('table', default_options)
      
      collection_presenter.table
    end
    it "should override the default options if specific options are given" do
      specific_options = {
        :collection => :a,
        :context => :b,
        :template_name => :c,
        :separator => :d
      }
      flexmock(collection_presenter).should_receive(:render_partial).once.with('table', specific_options)
      
      collection_presenter.table(specific_options)
    end
  end
  
  describe "pagination" do
    it "should call render_partial and return the rendered result" do
      flexmock(collection_presenter).should_receive(:render_partial).and_return(:result)
      
      collection_presenter.pagination.should == :result
    end
    it "should call render_partial with the right parameters" do
      default_options = {
        :collection => collection_mock,
        :context => context_mock,
        :template_name => :pagination,
        :separator => nil
      }
      flexmock(collection_presenter).should_receive(:render_partial).once.with(:pagination, default_options)
      
      collection_presenter.pagination
    end
    it "should override the default options if specific options are given" do
      specific_options = {
        :collection => :a,
        :context => :b,
        :template_name => :c,
        :separator => :d
      }
      flexmock(collection_presenter).should_receive(:render_partial).once.with(:c, specific_options)
      
      collection_presenter.pagination(specific_options)
    end
  end
  
  describe "render_partial" do
    it "should call instance eval on the context" do
      context_mock.should_receive(:instance_eval).once
      
      collection_presenter.send :render_partial, :some_name, :some_params
    end
    it "should render the partial in the 'context' context" do
      context_mock.should_receive(:render).once
      
      collection_presenter.send :render_partial, :some_name, :some_params
    end
    it "should call render partial on context with the passed through parameters" do
      context_mock.should_receive(:render).once.with(:partial => 'presenters/collection/some_name', :locals => { :a => :b })
      
      collection_presenter.send :render_partial, 'some_name', { :a => :b }
    end
  end
  
end