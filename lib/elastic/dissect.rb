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
  # DISSECT enables you to extract structured data out of a string.
  # @see https://www.elastic.co/docs/reference/query-languages/esql/esql-process-data-with-dissect-grok
  module Dissect
    # @param [String] input The column that contains the string you want to structure. If the column has multiple
    #                 values, DISSECT will process each value.
    # @param [String] pattern A dissect pattern. If a field name conflicts with an existing column,
    #                 the existing column is dropped. If a field name is used more than once, only
    #                 the right most duplicate creates a column.
    # @param [String] separator A string used as the separator between appended values, when using
    #                 the append modifier.
    # @example
    #   esql.dissect('a', '%{date} - %{msg} - %{ip}')
    #   esql.dissect('a', '%{date} - %{msg} - %{ip}', ',')
    #
    # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-dissect
    def dissect(input, pattern, separator = nil)
      query = "#{input} \"\"\"#{pattern}\"\"\""
      query.concat " APPEND_SEPARATOR=\"#{separator}\"" if separator
      @query[:dissect] = query
      self
    end
  end
end
