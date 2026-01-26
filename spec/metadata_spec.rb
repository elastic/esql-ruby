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
  context 'METADATA' do
    let(:esql) { ESQL.from('sample_data') }

    it 'accepts 2 strings as a parameter' do
      esql.metadata!('_index', '_id')
      expect(esql.query).to eq 'FROM sample_data METADATA _index, _id'
    end

    it 'accepts a string as a parameter' do
      esql.metadata!('_id')
      expect(esql.query).to eq 'FROM sample_data METADATA _id'
    end

    it 'accepts a comma separated string as a parameter' do
      esql.metadata!('_index, _id, _source, _size')
      expect(esql.query).to eq 'FROM sample_data METADATA _index, _id, _source, _size'
    end

    it 'accepts several comma separated string as a parameter' do
      esql.metadata!('_index, _id', '_source, _size')
      expect(esql.query).to eq 'FROM sample_data METADATA _index, _id, _source, _size'
    end

    it 'does not mutate when using metadata' do
      expect(esql.metadata('_index').object_id).not_to eq esql.object_id
    end
  end
end
