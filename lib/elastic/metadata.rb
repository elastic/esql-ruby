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
  # Access Metadata fields
  module Metadata
    # ES|QL can access document metadata fields.
    # To access these fields, use the METADATA directive with the FROM source command.
    # Only the FROM command supports the METADATA directive.
    #
    # @param [String, Array<String>]
    # @raise [ArgumentError] if the query has no FROM source command
    # @example
    #   esql.from('index').metadata('_index', '_id')
    #
    # @see https://www.elastic.co/docs/reference/query-languages/esql/esql-metadata-fields
    #
    def metadata!(*params)
      raise ArgumentError, 'A FROM source command must be used for metadata' unless @query[:from]

      @metadata << params
      self
    end

    def metadata(*params)
      esql = clone
      esql.instance_variable_set('@metadata', esql.instance_variable_get('@metadata').clone)
      esql.metadata!(*params)
      esql
    end
  end
end
