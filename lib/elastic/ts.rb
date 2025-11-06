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
  # The TS source command is similar to the FROM source command, with the following key differences:
  # * Targets only time series indices
  # * Enables the use of time series aggregation functions inside the STATS command
  #
  module TS
    # @param [String] index_pattern A list of indices, data streams or aliases. Supports wildcards and date math.
    # @param [String,Array<String>] fields A comma-separated list of metadata fields to retrieve.
    #
    # @example
    #
    #   query = Elastic::ESQL.ts(index_pattern, ['_index', '_id'])
    #
    # @see https://www.elastic.co/docs/reference/query-languages/esql/esql-metadata-fields
    #
    def ts(index_pattern, fields = nil)
      @query[:ts] = if fields
                      "#{index_pattern} METADATA #{parse_fields(fields)}"
                    else
                      index_pattern
                    end
      self
    end

    private

    def parse_fields(fields)
      if fields.is_a?(Array)
        fields.join(', ')
      elsif fields.is_a?(String)
        fields
      else
        raise ArgumentError, <<~EX
          The fields parameter for the TS command is a comma-separated list of metadata fields to retrieve.
          This has to be passed as an Array (['_index', '_id']) or a String ('_index, _id')
        EX
      end
    end
  end
end
