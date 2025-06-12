# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. Elasticsearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

module Elastic
  # The ROW source command produces a row with one or more columns with values that you specify.
  module Row
    # @param [Hash] params. Receives a Hash<column, value>
    # @options [String] column name: The column name. In case of duplicate column names, only the
    #                                rightmost duplicate creates a column.
    # @options [String] value: The value for the column. Can be a literal, an expression, or a function.
    #
    # @example
    #
    #   query.from('sample').row({ a: 1, b: 'two', c: nil })
    #
    # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/source-commands#esql-row
    #
    def row(params)
      raise ArgumentError, 'test' unless params.is_a?(Hash)

      @query[:row] = params.map { |k, v| "#{k} = #{v}" }.join(', ')
      self
    end
  end
end
