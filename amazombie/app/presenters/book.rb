class Presenters::Book < Presenters::Project
  
  model_reader :pages
  
  def url
    # url_for pages, '#'
  end
  
end