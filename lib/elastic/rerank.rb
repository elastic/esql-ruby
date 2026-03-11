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
  # The RERANK command uses an inference model to compute a new relevance score for an initial set
  # of documents, directly within your ES|QL queries.
  # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/rerank
  class Rerank
    # Once you call +rerank+ on an +Elastic::ESQL+ object, you can chain +on+ and +with+ to it.
    # @param [String] column The name of the output column containing the reranked scores. If not
    # specified, the results will be stored in a column named _score. If the specified column
    # already exists, it will be overwritten with the new results. (Optional)
    # @param [String] query The query text used to rerank the documents. This is typically the same
    # query used in the initial search.
    def initialize(esql, query: '', column: nil)
      @column = column
      @query = query
      @esql = esql
    end

    # @param [Array|String] field One or more fields to use for reranking. These fields should
    # contain the text that the reranking model will evaluate.
    def on(fields)
      @fields = fields.is_a?(String) ? fields : fields.join(', ')
      self
    end

    # @param [Hash] my_inference_endpoint - The ID of the inference endpoint to use for the task.
    # The inference endpoint must be configured with the rerank task type.
    def with(my_inference_endpoint)
      @inference_id = "WITH { \"inference_id\" : \"#{my_inference_endpoint}\" }"
      self
    end

    def to_query
      query = []
      query << if @column
                 "#{@column} = \"#{@query}\""
               else
                 "\"#{@query}\""
               end
      query << "ON #{@fields}" if @fields
      query << @inference_id if @inference_id
      query.join(' ')
    end

    private

    def method_missing(name, *args)
      @esql.send(name, *args)
    end

    def respond_to_missing?(method_name, *args)
      super
    end
  end
end
