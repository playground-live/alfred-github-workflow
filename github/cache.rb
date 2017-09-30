require_relative 'cache/store'
# include cache_store
class Github
  module Cache
    include Store
  end
end