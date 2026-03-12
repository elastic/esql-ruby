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
  # The FUSE processing command merges rows from multiple result sets and assigns new relevance scores.
  # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/fuse
  module Fuse
    # @param [String] fuse_method Defaults to RRF. Can be one of RRF (for Reciprocal Rank Fusion) or
    #                             LINEAR (for linear combination of scores). Designates which method
    #                             to use to assign new relevance scores.
    def fuse(fuse_method = nil)
      @query[:fuse] = fuse_method&.to_s&.upcase
      self
    end

    # @param [String|Hash] fields A String or Hash with the information for the with query.
    def with(fields)
      fields = display_hash(fields) if fields.is_a?(Hash)
      @query[:fuse].concat " WITH #{fields}"
      self
    end

    private

    # rubocop:disable Metrics/MethodLength
    def display_hash(hash)
      display = hash.keys.map do |key|
        hash[key] = if hash[key].is_a?(Hash)
                      display_hash(hash[key])
                    elsif hash[key].is_a?(String)
                      "\"#{hash[key]}\""
                    else
                      hash[key]
                    end
        "\"#{key}\": #{hash[key]}"
      end.join(', ')
      "{ #{display} }"
    end
    # rubocop:enable Metrics/MethodLength
  end
end
