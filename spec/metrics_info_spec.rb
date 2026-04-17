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

describe Elastic::ESQL do
  context 'METRICS_INFO' do
    let(:esql) { ESQL.ts('k8s') }

    it 'bulds a basic query' do
      expect(esql.metrics_info.sort('metric_name').query).to eq 'TS k8s | METRICS_INFO | SORT metric_name'
    end

    it 'builds query with where' do
      expect(
        esql.where(cluster: 'prod').metrics_info.sort('metric_name').query
      ).to eq 'TS k8s | WHERE cluster == "prod" | METRICS_INFO | SORT metric_name'
    end

    it 'builds a query selecting specific columns' do
      expect(
        esql.where(cluster: 'prod').metrics_info.keep('metric_name', 'metric_type').sort('metric_name').query
      ).to eq 'TS k8s | WHERE cluster == "prod" | METRICS_INFO | KEEP metric_name, metric_type | SORT metric_name'
    end

    it 'builds a query to count matching metrics' do
      expect(
        esql.metrics_info
            .where('metric_name LIKE "network.total*"')
            .stats({ column: 'matching_metrics', count_distinct: 'metric_name' })
            .query
      ).to eq 'TS k8s | METRICS_INFO | WHERE metric_name LIKE "network.total*" | ' \
              'STATS matching_metrics = COUNT_DISTINCT(metric_name)'
    end
  end
end
