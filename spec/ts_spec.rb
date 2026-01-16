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
  context 'TS' do
    it 'shows the expected queries' do
      expect(Elastic::ESQL.ts('sample').query).to eq 'TS sample'
    end

    it 'instantiates' do
      expect(Elastic::ESQL.ts('sample')).to be_a Elastic::ESQL
    end

    it 'allows changing TS' do
      esql = Elastic::ESQL.ts('sample')
      esql.ts('something_else')
      expect(esql.query).to eq 'TS something_else'
    end

    it 'accepts fields as Array' do
      fields = %w[_index _id]
      esql = Elastic::ESQL.ts('sample', fields)
      expect(esql.query).to eq 'TS sample METADATA _index, _id'
    end

    it 'accepts fields as String' do
      fields = '_index, _id'
      esql = Elastic::ESQL.ts('sample', fields)
      expect(esql.query).to eq 'TS sample METADATA _index, _id'
    end

    it 'raises error if the parameters are wrong' do
      expect do
        fields = { a: '_index ' }
        Elastic::ESQL.ts('sample', fields)
      end.to raise_error ArgumentError
    end
  end
end
# rubocop:enable Metrics/BlockLength
