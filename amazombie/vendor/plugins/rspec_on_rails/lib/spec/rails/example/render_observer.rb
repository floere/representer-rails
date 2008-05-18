require 'flexmock'

module Spec
  module Rails
    module Example
      # Provides specialized mock-like behaviour for controller and view examples,
      # allowing you to mock or stub calls to render with specific arguments while
      # ignoring all other calls.
      module RenderObserver
        include FlexMock::MockContainer
        
        # Similar to mocking +render+ with the exception that calls to +render+ with
        # any other options are passed on to the receiver (i.e. controller in
        # controller examples, template in view examples).
        #
        # This is necessary because Rails uses the +render+ method on both
        # controllers and templates as a dispatcher to render different kinds of
        # things, sometimes resulting in many calls to the render method within one
        # request. This approach makes it impossible to use a normal mock object, which
        # is designed to observe all incoming messages with a given name.
        #
        # +expect_render+ is auto-verifying, so failures will be reported without
        # requiring you to explicitly request verification.
        #
        # Also, +expect_render+ uses parts of RSpec's mock expectation framework. Because
        # it wraps only a subset of the framework, using this will create no conflict with
        # other mock frameworks if you choose to use them. Additionally, the object returned
        # by expect_render is an RSpec mock object, which means that you can call any of the
        # chained methods available in RSpec's mocks.
        #
        # == Controller Examples
        #
        #   controller.expect_render(:partial => 'thing', :object => thing)
        #   controller.expect_render(:partial => 'thing', :collection => things).once
        #
        #   controller.stub_render(:partial => 'thing', :object => thing)
        #   controller.stub_render(:partial => 'thing', :collection => things).twice
        #
        # == View Examples
        #
        #   template.expect_render(:partial => 'thing', :object => thing)
        #   template.expect_render(:partial => 'thing', :collection => things)
        #
        #   template.stub_render(:partial => 'thing', :object => thing)
        #   template.stub_render(:partial => 'thing', :collection => things)
        #
        def expect_render(opts={})
          register_verify_after_each
          store_rendering_options opts
          expect_render_mock_proxy.should_receive(:render).with(opts).at_least.once
        end

        # This is exactly like expect_render, with the exception that the call to render will not
        # be verified. Use this if you are trying to isolate your example from a complicated render
        # operation but don't care whether it is called or not.
        def stub_render(opts={})
          register_verify_after_each
          store_rendering_options opts
          expect_render_mock_proxy.should_receive(:render).with(opts).by_default
        end
          
        def verify_rendered # :nodoc:
          expect_render_mock_proxy.flexmock_verify
        end
        
        def unregister_verify_after_each #:nodoc:
          proc = verify_rendered_proc
          Spec::Rails::Example::RailsExampleGroup.remove_after(:each, &proc)
        end
        
        protected
        
        def store_rendering_options(opts) #:nodoc:
          @_render_opts ||= []
          @_render_opts << opts
        end
        
        def verify_rendered_proc #:nodoc:
          template = self
          @verify_rendered_proc ||= Proc.new do
            template.verify_rendered
            template.unregister_verify_after_each
          end
        end
        
        def register_verify_after_each #:nodoc:
          proc = verify_rendered_proc
          Spec::Rails::Example::RailsExampleGroup.after(:each, &proc)
        end
        
        def expect_render_mock_proxy #:nodoc:
          @expect_render_mock_proxy ||= flexmock("expect_render_mock_proxy")
        end
          
      end
    end
  end
end
