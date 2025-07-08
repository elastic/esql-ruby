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
  context 'KEEP' do
    let(:esql) { Elastic::ESQL.from('sample_data') }

    it 'accepts 2 strings as a parameter' do
      esql.keep!('column1', 'column2')
      expect(esql.query).to eq 'FROM sample_data | KEEP column1, column2'
    end

    it 'accepts a string as a parameter' do
      esql.keep!('column1')
      expect(esql.query).to eq 'FROM sample_data | KEEP column1'
    end

    it 'accepts a string with several columns as a parameter' do
      esql.keep!('column1, column2, column3')
      expect(esql.query).to eq 'FROM sample_data | KEEP column1, column2, column3'
    end

    it 'accepts backticks in column names as identifiers' do
      esql.keep!('`1.field`')
      expect(esql.query).to eq 'FROM sample_data | KEEP `1.field`'
    end

    it 'does not change the object when using keep' do
      esql.keep('column1', 'column2')
      expect(
        esql.keep('column1, column2').object_id
      ).not_to eq esql.object_id
      expect(esql.query).to eq 'FROM sample_data'
    end
  end
end
# rubocop:enable Metrics/BlockLength
