require_relative 'cache/store'

class Github
  # include cache_store
  module Cache
    include Store
  end
end
