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
  context 'STATS' do
    it 'writes a stats query with column, by, where and functions' do
      stat = { column: 'fernando', count: 'emp_no', by: 'language', where: 'a = 1' }
      esql = Elastic::ESQL.from('sample_data').stats(stat)
      expect(esql.query).to eq 'FROM sample_data | STATS fernando = COUNT(emp_no) WHERE a = 1 BY language'
    end

    it 'writes a query with several stats' do
      stats = [
        { column: 'avg50s', avg: 'salary::LONG', where: 'birth_date < "1960-01-01"' },
        { column: 'avg60s', avg: 'salary::LONG', where: 'birth_date >= "1960-01-01"' }
      ]
      esql = Elastic::ESQL.from('employees').stats(stats).by('gender').sort('gender')
      expect(esql.query).to eq(
        'FROM employees | ' \
        'STATS avg50s = AVG(salary)::LONG ' \
        'WHERE birth_date < "1960-01-01", ' \
        'avg60s = AVG(salary)::LONG ' \
        'WHERE birth_date >= "1960-01-01" BY gender | SORT gender'
      )
    end

    it 'runs this one too' do
      esql = Elastic::ESQL.from('employees').where('emp_no == 10020').stats({ column: 'is_absent',
                                                                              absent: 'languages' })
      expect(esql.query).to eq(
        'FROM employees | WHERE emp_no == 10020 | STATS is_absent = ABSENT(languages)'
      )
    end

    it 'accepts nested functions' do
      stats = { column: 'distinct_word_count', count_distinct: { split: 'words, ";"' } }
      esql = Elastic::ESQL.row(words: '"foo;bar;baz;qux;quux;foo"').stats(stats)
      expect(esql.query).to eq(
        'ROW words = "foo;bar;baz;qux;quux;foo" ' \
        '| STATS distinct_word_count = COUNT_DISTINCT(SPLIT(words, ";"))'
      )
    end

    it 'uses two functions' do
      stats = { median: 'salary', median_absolute_deviation: 'salary' }
      esql = Elastic::ESQL.from('employees').stats(stats)
      expect(esql.query).to eq('FROM employees | STATS MEDIAN(salary), MEDIAN_ABSOLUTE_DEVIATION(salary)')
    end

    it 'uses TS' do
      stats = { avg: { rate: 'requests, 10m' } }
      esql = Elastic::ESQL.ts('metrics').where('TRANGE(1h)').stats(stats).by('TBUCKET(1m), host')
      expect(esql.query).to eq(
        'TS metrics ' \
        '| WHERE TRANGE(1h) ' \
        '| STATS AVG(RATE(requests, 10m)) BY TBUCKET(1m), host'
      )
    end

    it 'uses more TS' do
      esql = Elastic::ESQL.ts('k8s')
                          .where('cluster == "prod"')
                          .where('pod == "two"')
                          .stats({ column: 'events_received', max: { absent_over_time: 'events_received' } })
                          .by('pod, time_bucket = TBUCKET(2 minute)')
      # https://www.elastic.co/docs/reference/query-languages/esql/functions-operators/time-series-aggregation-functions
      expect(esql.query).to eq(
        'TS k8s | WHERE cluster == "prod" AND pod == "two" ' \
        '| STATS events_received = MAX(ABSENT_OVER_TIME(events_received)) ' \
        'BY pod, time_bucket = TBUCKET(2 minute)'
      )
    end

    it 'runs other examples from TS agg doc page' do
      stats = {
        column: 'events_received',
        max: { absent_over_time: 'events_received' },
        by: 'pod, time_bucket = TBUCKET(2 minute)'
      }
      expect(
        Elastic::ESQL.ts('k8s')
          .where('cluster == "prod"')
          .where('pod == "two"')
          .stats(stats).query
      ).to eq(
        'TS k8s ' \
        '| WHERE cluster == "prod" AND pod == "two" ' \
        '| STATS events_received = MAX(ABSENT_OVER_TIME(events_received)) BY pod, time_bucket = TBUCKET(2 minute)'
      )

      expect(
        Elastic::ESQL.ts('k8s')
          .stats(
            [
              { column: 'distincts', count_distinct: { count_distinct_over_time: 'network.cost' } },
              { column: 'distincts_imprecise', count_distinct: { count_distinct_over_time: 'network.cost, 100' } }
            ]
          ).by('cluster, time_bucket = TBUCKET(1minute)').query
      ).to eq(
        'TS k8s ' \
        '| STATS distincts = COUNT_DISTINCT(COUNT_DISTINCT_OVER_TIME(network.cost)), ' \
        'distincts_imprecise = COUNT_DISTINCT(COUNT_DISTINCT_OVER_TIME(network.cost, 100)) ' \
        'BY cluster, time_bucket = TBUCKET(1minute)'
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
