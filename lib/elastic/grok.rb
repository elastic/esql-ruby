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
  # GROK enables you to extract structured data out of a string.
  module Grok
    # @param [String] input The column that contains the string you want to structure. If the column
    #                 has multiple values, GROK will process each value.
    # @param [String] pattern A grok pattern. If a field name conflicts with an existing column, the
    #                 existing column is discarded. If a field name is used more than once, a
    #                 multi-valued column will be created with one value per each occurrence of the
    #                 field name.
    # @example
    #   esql.grok('a', '%{date} - %{msg} - %{ip}')
    # @see https://www.elastic.co/docs/reference/query-languages/esql/esql-process-data-with-dissect-grok
    def grok(input, pattern)
      @query[:grok] = "#{input} \"\"\"#{pattern}\"\"\""
      self
    end
  end
end
