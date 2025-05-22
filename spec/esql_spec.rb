# Licensed to Elasticsearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
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
  context 'when initializing' do
    let(:esql) { Elastic::ESQL.from('sample_data') }

    it 'shows the expected queries' do
      expect(esql.run).to eq 'FROM sample_data'
    end

    it 'allows to change FROM' do
      expect(esql.from('something_else').run).to eq 'FROM something_else'
    end

    it 'uses limit' do
      expect(esql.limit(2).run).to eq 'FROM sample_data | LIMIT 2'
    end

    it 'returns the full query' do
      expect(
        esql.sort('@timestamp').ascending.limit(2).where('value > 10').query
      ).to eq 'FROM sample_data | SORT @timestamp ASC | LIMIT 2 | WHERE value > 10'
    end

    it 'saves query data and returns with .query' do
      esql.sort('@timestamp').ascending.limit(2).where('value > 10')
      expect(
        esql.query
      ).to eq 'FROM sample_data | SORT @timestamp ASC | LIMIT 2 | WHERE value > 10'
    end

    it 'returns query with to_s' do
      expect("#{esql}").to eq esql.query
      expect(esql.to_s).to eq esql.query
    end

    it 'allows instantiation of empty ESQL' do
      expect(Elastic::ESQL.new.class).to eq Elastic::ESQL
    end

    it 'raises error if no source command specified' do
      esql = Elastic::ESQL.new
      expect { esql.query }.to raise_error ArgumentError
    end

    it 'instantiates with from' do
      expect(Elastic::ESQL.from('sample_data').run).to eq 'FROM sample_data'
    end
  end
end
