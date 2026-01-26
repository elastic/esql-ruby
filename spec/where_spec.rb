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
  context 'WHERE' do
    let(:esql) { ESQL.from('sample_data') }

    it 'uses WHERE' do
      expect(esql.where('name LIKE "Something"').to_s).to eq 'FROM sample_data | WHERE name LIKE "Something"'
    end

    it 'escapes double quotes for String literals' do
      expect(
        esql.where('first_name == "Georgi"').query
      ).to eq 'FROM sample_data | WHERE first_name == "Georgi"'
    end

    it 'concatenates WHERE chained methods' do
      expect(
        esql
          .where('first_name == "Juan"')
          .where('last_name == "Perez"')
          .where('age > 18').query
      ).to eq 'FROM sample_data | WHERE first_name == "Juan" AND last_name == "Perez" AND age > 18'
    end

    it 'mutates the query object' do
      esql
        .where!('first_name == "Juan"')
        .where!('last_name == "Perez"')
        .where!('age > 18').query
      expect(esql.to_s).to eq 'FROM sample_data | WHERE first_name == "Juan" AND last_name == "Perez" AND age > 18'
    end

    it 'uses the other where format' do
      expect(esql.where('first_name: "Juan"').query).to eq 'FROM sample_data | WHERE first_name: "Juan"'
    end
  end
end
# rubocop:enable Metrics/BlockLength
