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
  # The URI_PARTS processing command parses a Uniform Resource Identifier (URI) string and extracts
  # its components into new columns.
  module URIParts
    # @param prefix [String] The prefix for the output columns. The extracted parts are available as prefix.component.
    # @param expression [String] The string expression containing the URI to parse.
    # @example
    #   esql = ESQL.row(uri: uri).uri_parts('parts', 'uri').keep('parts.*')
    # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/uri-parts
    def uri_parts!(prefix, expression)
      @query[:uri_parts] = "#{prefix} = #{expression}"
      self
    end

    def uri_parts(prefix, expression)
      method_copy(prefix, expression)
    end
  end
end
