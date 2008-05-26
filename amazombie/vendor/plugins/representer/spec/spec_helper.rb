require 'spec'
require 'flexmock'
require 'active_support'
require 'action_controller'

$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '../lib')

# Set up flexmock as mock framework
Spec::Runner.configure do |config|
  config.mock_with :flexmock
end

require File.join(File.dirname(__FILE__), '../init')

# Common helpers for view specs.
#
module ViewSpecHelper
  
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

# Used to test private methods.
#
# The idea is to replace instance.send :private_method.
# Now it is rather like:
# We have the scenario we are in the given instance.
#
def in_the(instance, &block)
  instance.instance_eval(&block)
end