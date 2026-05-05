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
  # The PROMQL source command queries time series indices using Prometheus Query Language (PromQL).
  # Like TS, it enables time series aggregation functions, but accepts PromQL syntax instead of
  # ES|QL.
  module PromQL
    PROMQL_PARAMETERS = [:index, :step, :buckets, :start, :end, :scrape_interval, :result, :expression].freeze
    # @param [Hash] params The PROMQL command accepts zero or more space-separated key value options
    #                      followed by named PromQL expression.
    # @option params [String] :index A list of indices, data streams, or aliases. Supports wildcards
    #                                and date math. Defaults to * querying all indices with
    #                                index.mode: time_series.
    # @option params [String] :step Query resolution step width (optional). Automatically determined
    #                               given the number of target +buckets+ and the selected time
    #                               range.
    # @option params [String] :buckets Target number of buckets for auto-step derivation. Defaults
    #                                  to +100+. Mutually exclusive with +step+. Requires a known
    #                                  time range, either by setting start and end explicitly or
    #                                  implicitly through Kibana's time range filter.
    # @option params [String] :start Start time of the query, inclusive (optional). Uses the start
    #                                based on Kibana's date picker or unrestricted if missing.
    # @option params [String] :end End time of the query, inclusive (optional). Uses the end based
    #                              on Kibana's date picker or unrestricted if missing.
    # @option params [String] :scrape_interval The expected metric collection interval. Defaults to
    #                                          +1m+. Used to determine implicit range selector
    #                                          windows as +max(step, scrape_interval)+.
    # @option params [String] :result Name of the output column with the query result timeseries
    #                                 (optional). By default, the name of the output column is the
    #                                 PromQL expression itself.
    #
    # @example
    #   Elastic::ESQL.promql(index: 'k8', step: '1h', result: 'result', expression: '(sum by (cluster) (network.cost))')
    #
    # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/promql
    #
    def promql(params)
      validate_params(params.keys)
      @query[:promql] = promql_query(params)
      self
    end

    private

    def validate_params(params)
      params.each do |param|
        raise ArgumentError, "#{param} is not a valid parameter for PROMQL" unless PROMQL_PARAMETERS.include?(param)
      end
    end

    def promql_query(params)
      query = []
      result = params.delete(:result)
      expression = params.delete(:expression)
      query += process_promql_params(params)
      query << (result ? "#{result}=#{expression}" : expression)
      query.join(' ')
    end

    def process_promql_params(params)
      params.map do |k, v|
        if [:start, :end].include?(k)
          "#{k}=\"#{v}\""
        else
          "#{k}=#{v}"
        end
      end
    end
  end
end
