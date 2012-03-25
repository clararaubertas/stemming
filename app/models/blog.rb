class Blog
  
  include Singleton
  attr_reader :name
  
  def initialize
    @name = "Stemming.org" # choose the name of your blog here
  end
  
end
