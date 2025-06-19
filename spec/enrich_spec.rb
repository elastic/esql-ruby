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

# rubocop:disable Metrics/BlockLength
describe Elastic::ESQL do
  context 'ENRICH' do
    let(:esql) { Elastic::ESQL.from('sample_data') }

    it 'initializes a single enrich' do
      esql.enrich('policy')
      expect(esql.to_s).to eq 'FROM sample_data | ENRICH policy'
    end

    it 'builds an enrich with on' do
      esql.enrich('policy').on('a')
      expect(esql.to_s).to eq 'FROM sample_data | ENRICH policy ON a'
    end

    it 'builds an enrich and with' do
      esql.enrich('policy').with('name')
      expect(esql.to_s).to eq 'FROM sample_data | ENRICH policy WITH name'
    end

    it 'builds an enrich and `with` with a Hash parameter' do
      esql.enrich('policy').with({ name: 'language_name' })
      expect(esql.to_s).to eq 'FROM sample_data | ENRICH policy WITH name = language_name'
    end

    it 'builds an enrich and `with` with a Hash parameter and more params' do
      esql.enrich('policy').with({ name: 'language_name', coso: 'thing' })
      expect(esql.to_s).to eq 'FROM sample_data | ENRICH policy WITH name = language_name, coso = thing'
    end

    it 'builds an enrich with on and with' do
      esql.enrich('policy').on('a').with('name')
      expect(esql.to_s).to eq 'FROM sample_data | ENRICH policy ON a WITH name'
    end

    it 'works fine when continuing chainging' do
      esql.enrich('policy').sort('@timestamp')
      expect(esql.to_s).to eq 'FROM sample_data | SORT @timestamp | ENRICH policy'
    end
  end
end
# rubocop:enable Metrics/BlockLength
