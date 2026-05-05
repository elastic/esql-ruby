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

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe Elastic::ESQL do
  context 'PROMQL' do
    it 'builds a query with index' do
      esql = ESQL.promql(index: 'metrics-*', expression: 'sum by (instance) (rate(http_requests_total))')
      expect(esql.query).to eq 'PROMQL index=metrics-* sum by (instance) (rate(http_requests_total))'
    end

    it 'builds a query with more parameters' do
      esql = ESQL.promql(
        index: 'k8s',
        step: '5m',
        start: '2024-05-10T00:20:00.000Z',
        end: '2024-05-10T00:25:00.000Z',
        expression: '(sum(avg_over_time(network.cost[5m])))'
      )
      expect(esql.query).to eq 'PROMQL index=k8s step=5m ' \
                               'start="2024-05-10T00:20:00.000Z" ' \
                               'end="2024-05-10T00:25:00.000Z" ' \
                               '(sum(avg_over_time(network.cost[5m])))'
    end

    it 'buils a query with named result' do
      esql = ESQL.promql(
        index: 'k8s',
        step: '1h',
        result: 'result',
        expression: '(sum by (cluster) (network.cost))'
      ).sort('result')
      expect(esql.query).to eq 'PROMQL index=k8s step=1h ' \
                               'result=(sum by (cluster) (network.cost)) ' \
                               '| SORT result'
    end

    it 'buils another query from the examples' do
      expression = '(max by (cluster) (network.total_bytes_in{cluster!="prod"}))'
      esql = ESQL.promql(
        index: 'k8s',
        step: '1h',
        result: 'cost',
        expression: expression
      ).sort('cluster')
      expect(esql.query).to eq 'PROMQL index=k8s step=1h ' \
                               "cost=#{expression} " \
                               '| SORT cluster'
    end

    it 'raises error if the parameters are wrong' do
      expect do
        ESQL.promql(example_parameter: 'wrong')
      end.to raise_error(ArgumentError, 'example_parameter is not a valid parameter for PROMQL')
    end
  end
end
# rubocop:enable Metrics/BlockLength
