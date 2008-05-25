# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
# require File.dirname(__FILE__) + '/stubs'
# require File.dirname(__FILE__) + '/shared_examples'

#################################################
# Configuration
#
Spec::Runner.configure do |config|
  # config.use_transactional_fixtures = true
  # config.use_instantiated_fixtures  = false
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  config.mock_with :flexmock
end


#################################################
# Ferret handling
#

# for in-memory ferret index
# require File.expand_path(File.dirname(__FILE__)) + '/in_memory_ferret_setup'

# Run all tests with ferret disabled.
# Enable ferret for single tests and single classes with 'setup_ferret_for Klass' below.
#  
# [Profile::Member, Profile::Band, Profile::Label, Profile::Venue, Event::Event, MemberFeedback].each do |model|
#   model.disable_ferret if model.respond_to?(:disable_ferret)
# end

# class FerretAlreadyEnabledError < StandardError; end

# Enables ferret for klass and empties the index.
# Should be called in the before(:all) block of specs concerning ferret.
#
# def setup_ferret_for(klass)
# 
#   already_disabled_msg = <<-EOF
#     You should disable ferret for #{klass} generally in the spec_helper
#     (and probably the test_helper, too) before enabling it for this specific
#     spec. Or perhaps it is generally disabled but you forgot to call
#     'teardown_ferret_for #{klass}' in a previous spec?"
#   EOF
# 
#   raise FerretAlreadyEnabledError, already_disabled_msg if klass.ferret_enabled?
# 
#   klass.enable_ferret
#   index = klass.aaf_index.ferret_index
#   index.size.times {|i| index.delete(i)}
# end

# Disables ferret and leaves the index as it's been before: empty.
# Should be called in the after(:all) block of specs concerning ferret.
#
# def teardown_ferret_for(klass)
#   index = klass.aaf_index.ferret_index
#   index.size.times {|i| index.delete(i)}
#   klass.disable_ferret
# end


#################################################
# Helpers
#

# Common helpers for controller specs
#
module ControllerSpecHelper
  
  # Sets the controller's current member
  #
  def mock_login_of(member)
    user = member ? member.user : nil
    flexmock(@controller) do |mock| 
      mock.should_receive(:current_member).and_return(member)
      mock.should_receive(:current_user).and_return(user)
    end
  end
end

# Common helpers for controller specs
#
module ViewSpecHelper
  include ApplicationHelper
  # include SimplyHelpful::RecordIdentificationHelper
  
  # Sets the view's current member
  #
  def mock_login_of(member)
    user = member ? member.user : nil
    flexmock(@controller.template) do |mock| 
      mock.should_receive(:current_member).and_return(member)
      mock.should_receive(:current_user).and_return(user)
    end
  end
  
  # Overrides the rspec template, returning the controller template.
  #
  def template
    raise '"template" test helper method only available in view/functional specs' unless @controller
    @controller.template
  end
  
  # Overrides the rspec template, wraps it with a flexmock.
  #
  def view
    flexmock(template)
  end
end

# Stubs the methods in the +attr+ hash for the given object.
#
def stub(obj, attrs={})
  flexmock(obj) do |mock| 
    attrs.each { |method, value| mock.should_receive(method).and_return(value).by_default }
  end
end

# Mocks the object with the expectations in the given block.
# 
# example: expect_to(@controller) {|c| c.should_receive(:can_edit?).with(@member).times(3).and_return(true)}
#
def expect_to(obj, &blk)
  flexmock(obj, &blk) #flexmock(obj) {|mock| blk.call(mock)}
end

##
# rSpec Hash additions.
#
# From 
#   * http://wincent.com/knowledge-base/Fixtures_considered_harmful%3F
#   * Neil Rahilly

class Hash

  ##
  # Filter keys out of a Hash.
  #
  #   { :a => 1, :b => 2, :c => 3 }.except(:a)
  #   => { :b => 2, :c => 3 }

  def except(*keys)
    self.reject { |k,v| keys.include?(k || k.to_sym) }
  end

  ##
  # Override some keys.
  #
  #   { :a => 1, :b => 2, :c => 3 }.with(:a => 4)
  #   => { :a => 4, :b => 2, :c => 3 }
  
  def with(overrides = {})
    self.merge overrides
  end

  ##
  # Returns a Hash with only the pairs identified by +keys+.
  #
  #   { :a => 1, :b => 2, :c => 3 }.only(:a)
  #   => { :a => 1 }
  
  def only(*keys)
    self.reject { |k,v| !keys.include?(k || k.to_sym) }
  end

end

# Monkey patch for making flash.now accessable in specs without rendering the view.
# http://www.pluitsolutions.com/2008/01/22/testing-flashnow-in-rails/
# 
# Example:
#   flash.now_cache[:error]
#
module ActionController
  module Flash 
    class FlashNow
      def initialize(flash)
        @flash = flash
        @flash[:now_cache] = {}
      end
      
      def []=(k, v)
        @flash[k] = v
        @flash.discard(k)
        @flash[:now_cache][k] = v
        v
      end
    end
    
    class FlashHash
      def now_cache
        self[:now_cache] || {}
      end
    end
  end 
end

# Prints a simply HTML-escaped version of the response body
#
def puts_response_body
  puts response.body.gsub('<', '&lt;').gsub('>', '&gt;')
end

# p rspec
def pr(obj)
  puts( obj.inspect.gsub('<', '&lt;').gsub('>', '&gt;').gsub('\"', '"') + "<br />" )
end

# A Controller Stub for presenter tests
class StubController < ApplicationController
  def rescue_action(e) raise e; end;
  attr_accessor :request, :url, :response, :current_member
end

def setup_controller_for_presenter_spec
  @controller                 ||= StubController.new
  @controller.request         = ActionController::TestRequest.new
  @controller.url             = ActionController::UrlRewriter.new(@controller.request, {})
  @controller.current_member  = member_stub
end

def whitespace_sanitized_response_body
  @response.body.gsub(/\s+/, ' ')
end

# Allows the definition of "describe-wide" examples and describes.
# 
# Case for "it". Use in the describe block:
# shared :it_should_behave_like_having_a_labels_class do
#   response.should have_tag('.labels')
# end
# Then, call it in the describe block or nested describe blocks as such:
# it_should_behave_like_having_a_labels_class
#
# Case for "describe". Use in the describe block:
# shared :describe_an_update_stream_item do
#   before(:each) do
#     # …
#   end
#   it "bla" do
#     response.should have_tag('.labels')
#   end
# end
# Then, call it in the describe block or nested describe blocks as such:
# describe_an_update_stream_item
#
def shared(name, &block)
  self.class.class_eval do
    define_method name do
      name_ary = name.to_s.split('_')
      method_name = name_ary.first.to_sym
      descr_name  = name_ary[1..-1].join(" ")
      if [:describe, :it].include? method_name
        self.send(method_name, descr_name, &block)
      else
        raise ArgumentError, "Shared it or describe needs to start with 'it_' or 'describe_'."
      end
    end
  end
end

def implicit
  # does nothing
end

# module BusinessProfileLoadingHelper
#   def mock_load_profile_by_urlname(profile)
#     flexmock(Profile::Business).should_receive(:find_by_url_id_with_deleted).once.and_return(profile)
#   end
# end

# Returns the full path of the fixture given by file name in the test directory
# (we can reuse these fixtures, no need to bloat the repo). 
#
def fixture_file_path(file_name)
  File.join(RAILS_ROOT, "test/fixtures/data", file_name)
end