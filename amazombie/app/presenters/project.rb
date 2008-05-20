class Presenters::Project < Presenters::Base
  
  context_method :read_fragment, :write_fragment
  # Handles fragment caching in presenters.
  # Use as follows:
  # cache "some_key" do
  #   create_a_new_fragment
  # end
  #
  # If the fragment with the given key is cached already,
  # it will use the fragment, else it will call the block code to get
  # a new fragment.
  # Note: return cannot be used inside the block. Return the new fragment
  # by making it the last statement inside the block.
  #
  def cache(name, &block)
    # check for a cached fragment
    (fragment=read_fragment(name)) and return fragment
    # get the fragment
    fragment = block.call
    # cache the fragment
    write_fragment(name, fragment, {})
    fragment
  end
  
  # TODO should go up? Nope. Add a Presenters::ActiveRecord::Base?
  model_reader :to_param
  
  # All of the rails' standard helpers.
  #
  helper ActionView::Helpers::ActiveRecordHelper
  helper ActionView::Helpers::TagHelper
  helper ActionView::Helpers::FormTagHelper
  helper ActionView::Helpers::FormOptionsHelper
  helper ActionView::Helpers::FormHelper
  helper ActionView::Helpers::UrlHelper
  helper ActionView::Helpers::AssetTagHelper
  helper ActionView::Helpers::PrototypeHelper
  helper ActionView::Helpers::TextHelper
  
  helper ApplicationHelper
  
end