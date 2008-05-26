# The Collection Presenter has the purpose of presenting
# collections with the following features:
# * Render as list
# * Render as table
# * Render as collection (not yet)
# * Page navigation
# 
# Prerequisites to using it are:
# * Controller action understands the page parameter
# * Model given needs to be a PaginationEnumeration 
# * Presenter of model needs to understand the message 'render_list_item'
# * Presenter of model needs to understand the message 'render_collection_item' (not yet)
#
# Use as follows:
#   - events = collection_presenter_for(@events)
#   / optionally with a template name to render, default is :list_item
#   / optionally with a tag separator like events.list(:list_item, tag('br')), default is <hr />
#   = events.list
#   = events.navigation / if you need a navigation
# 
# TODO
# class Helpers::Presenters::Collection
class Presenters::Collection
  
  def initialize(collection, context)
    @collection, @context = collection, context
  end
  
  # Renders a list (in the broadest sense of the word).
  #
  # Options:
  #   collection => collection to iterate over
  #   context => context to render in
  #   template_name => template to render for each model element
  #   separator => separator between each element
  # By default, uses:
  #   - The collection of the collection presenter to iterate over.
  #   - The original context given to the collection presenter to render in.
  #   - Uses 'list_item' as the default element template.
  #   - Uses a nil separator.
  #
  def list(options = {})
    default_options = {
      :collection => @collection,
      :context => @context,
      :template_name => :list_item,
      :separator => nil
    }
    
    render_partial 'list', default_options.merge(options)
  end
  
  # Renders a collection.
  #
  # Options:
  #   collection => collection to iterate over
  #   context => context to render in
  #   template_name => template to render for each model element
  #   separator => separator between each element
  # By default, uses:
  #   - The collection of the collection presenter to iterate over.
  #   - The original context given to the collection presenter to render in.
  #   - Uses 'collection_item' as the default element template.
  #   - Uses a nil separator.
  #
  def collection(options = {})
    default_options = {
      :collection => @collection,
      :context => @context,
      :template_name => :collection_item,
      :separator => nil
    }
    
    render_partial 'collection', default_options.merge(options)
  end
  
  # Renders a table.
  #
  # Options:
  #   collection => collection to iterate over
  #   context => context to render in
  #   template_name => template to render for each model element
  #   separator => separator between each element
  # By default, uses:
  #   - The collection of the collection presenter to iterate over.
  #   - The original context given to the collection presenter to render in.
  #   - Uses 'table_row' as the default element template.
  #   - Uses a nil separator.
  #
  def table(options = {})
    options = {
      :collection => @collection,
      :context => @context,
      :template_name => :table_row,
      :separator => nil
    }.merge(options)
    
    render_partial 'table', options
  end
  
  # Renders a pagination.
  #
  # Options:
  #   collection => collection to iterate over
  #   context => context to render in
  #   separator => separator between pages
  # By default, uses:
  #   - The collection of the collection presenter to iterate over.
  #   - The original context given to the collection presenter to render in.
  #   - Uses | as separator.
  #
  def pagination(options = {})
    options = {
      :collection => @collection,
      :context => @context,
      :separator => '|'
    }.merge(options)
    
    render_partial 'pagination', options
  end
  
  private
  
    def render_partial(name, locals)
      @context.instance_eval { render :partial => "presenters/collection/#{name}", :locals => locals }
    end
  
end