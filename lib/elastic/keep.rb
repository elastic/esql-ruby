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
  # KEEP enables you to specify what columns are returned and the order in which they are returned.
  module Keep
    # @param [String|Array<String>] columns A comma-separated list of columns to keep. Supports wildcards.
    # @example
    #   esql.keep('column1, column2')
    #   esql.keep('column1', 'column2')
    # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/processing-commands#esql-keep
    def keep!(*params)
      @query[:keep] = params.join(', ')
      self
    end

    def keep(*params)
      method_copy(:keep, params)
    end
  end
end
