class Presenters::Models::Book < Presenters::Restorm
  
  def load_list_item
    @pages = @model.pages
  end
  def load_collection_item
    @pages = @model.pages
  end
  def load_table_row
    @pages = @model.pages
  end
  
end