# Copyright Elasticsearch B.V. and/or licensed to Elasticsearch B.V. under one
# or more contributor license agreements. See the NOTICE file distributed with
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
  # Use the WHERE command to query the data.
  # TODO: WHERE supports several operators. For example, you can use LIKE to run a wildcard query
  # against the message column.
  module Where
    # @param [String] expression A boolean expression.
    # @example
    #   esql.where('name LIKE "Something"')
    #
    # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-where
    def where!(expression)
      if @query[:where]
        @query[:where] += " AND #{expression}"
      else
        @query[:where] = expression
      end
      self
    end

    def where(expression)
      method_copy(:where, expression)
    end
  end
end
