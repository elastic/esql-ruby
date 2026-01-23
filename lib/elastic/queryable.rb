require_relative 'limit'
require_relative 'sort'
require_relative 'where'

module Elastic
  module Queryable
    include Limit
    include Sort
    include Where
  end
end
