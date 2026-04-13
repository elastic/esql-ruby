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
  context 'INLINE STATS' do
    it 'writes a simple from query' do
      esql = ESQL.from('employees').inline_stats(column: 'avg_lang', avg: 'languages')
      expect(esql.query).to eq 'FROM employees | INLINE STATS avg_lang = AVG(languages)'
    end

    it 'writes the query to calculate multiple values' do
      inline_stats = [
        { column: 'avg_lang', avg: 'languages' },
        { column: 'max_lang', max: 'languages' }
      ]
      esql = ESQL.from('employees').inline_stats(inline_stats)
      expect(esql.query).to eq 'FROM employees | INLINE STATS avg_lang = AVG(languages), max_lang = MAX(languages)'
    end

    it 'writes a inline_stats query with column, by, where and functions' do
      stat = { column: 'fernando', count: 'emp_no', by: 'language', where: 'a = 1' }
      esql = ESQL.from('sample_data').inline_stats(stat)
      expect(esql.query).to eq 'FROM sample_data | INLINE STATS fernando = COUNT(emp_no) WHERE a = 1 BY language'
    end

    it 'writes a query with several inline_stats' do
      inline_stats = [
        { column: 'avg50s', avg: 'salary::LONG', where: 'birth_date < "1960-01-01"' },
        { column: 'avg60s', avg: 'salary::LONG', where: 'birth_date >= "1960-01-01"' }
      ]
      esql = ESQL.from('employees').inline_stats(inline_stats).by('gender').sort('gender')
      expect(esql.query).to eq(
        'FROM employees | ' \
        'INLINE STATS avg50s = AVG(salary)::LONG ' \
        'WHERE birth_date < "1960-01-01", ' \
        'avg60s = AVG(salary)::LONG ' \
        'WHERE birth_date >= "1960-01-01" BY gender | SORT gender'
      )
    end

    it 'writes a query with WHERE' do
      esql = ESQL.from('employees').where('emp_no == 10020').inline_stats({ column: 'is_absent',
                                                                            absent: 'languages' })
      expect(esql.query).to eq(
        'FROM employees | WHERE emp_no == 10020 | INLINE STATS is_absent = ABSENT(languages)'
      )
    end

    it 'accepts nested functions' do
      inline_stats = { column: 'distinct_word_count', count_distinct: { split: 'words, ";"' } }
      esql = ESQL.row(words: '"foo;bar;baz;qux;quux;foo"').inline_stats(inline_stats)
      expect(esql.query).to eq(
        'ROW words = "foo;bar;baz;qux;quux;foo" ' \
        '| INLINE STATS distinct_word_count = COUNT_DISTINCT(SPLIT(words, ";"))'
      )
    end

    it 'uses two functions' do
      inline_stats = { median: 'salary', median_absolute_deviation: 'salary' }
      esql = ESQL.from('employees').inline_stats(inline_stats)
      expect(esql.query).to eq('FROM employees | INLINE STATS MEDIAN(salary), MEDIAN_ABSOLUTE_DEVIATION(salary)')
    end

    it 'uses TS' do
      inline_stats = { avg: { rate: 'requests, 10m' } }
      esql = ESQL.ts('metrics').where('TRANGE(1h)').inline_stats(inline_stats).by('TBUCKET(1m), host')
      expect(esql.query).to eq(
        'TS metrics ' \
        '| WHERE TRANGE(1h) ' \
        '| INLINE STATS AVG(RATE(requests, 10m)) BY TBUCKET(1m), host'
      )
    end

    it 'uses more TS' do
      esql = ESQL.ts('k8s')
                 .where('cluster == "prod"')
                 .where('pod == "two"')
                 .inline_stats({ column: 'events_received', max: { absent_over_time: 'events_received' } })
                 .by('pod, time_bucket = TBUCKET(2 minute)')
      # https://www.elastic.co/docs/reference/query-languages/esql/functions-operators/time-series-aggregation-functions
      expect(esql.query).to eq(
        'TS k8s | WHERE cluster == "prod" AND pod == "two" ' \
        '| INLINE STATS events_received = MAX(ABSENT_OVER_TIME(events_received)) ' \
        'BY pod, time_bucket = TBUCKET(2 minute)'
      )
    end

    it 'runs other examples from TS agg doc page' do
      inline_stats = {
        column: 'events_received',
        max: { absent_over_time: 'events_received' },
        by: 'pod, time_bucket = TBUCKET(2 minute)'
      }
      expect(
        ESQL.ts('k8s')
          .where('cluster == "prod"')
          .where('pod == "two"')
          .inline_stats(inline_stats).query
      ).to eq(
        'TS k8s ' \
        '| WHERE cluster == "prod" AND pod == "two" ' \
        '| INLINE STATS events_received = MAX(ABSENT_OVER_TIME(events_received)) BY pod, time_bucket = TBUCKET(2 minute)'
      )

      expect(
        ESQL.ts('k8s')
          .inline_stats(
            [
              { column: 'distincts', count_distinct: { count_distinct_over_time: 'network.cost' } },
              { column: 'distincts_imprecise', count_distinct: { count_distinct_over_time: 'network.cost, 100' } }
            ]
          ).by('cluster, time_bucket = TBUCKET(1minute)').query
      ).to eq(
        'TS k8s ' \
        '| INLINE STATS distincts = COUNT_DISTINCT(COUNT_DISTINCT_OVER_TIME(network.cost)), ' \
        'distincts_imprecise = COUNT_DISTINCT(COUNT_DISTINCT_OVER_TIME(network.cost, 100)) ' \
        'BY cluster, time_bucket = TBUCKET(1minute)'
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
