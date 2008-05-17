class Presenters::Models::HumanHead < Presenters::Restorm
  
  def load_list_item
    @weight = @model.weight
  end
  def load_collection_item
    @weight = @model.weight
  end
  def load_table_row
    @weight = @model.weight
  end
  
end