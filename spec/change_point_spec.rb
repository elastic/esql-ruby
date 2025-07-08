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
  context 'CHANGE_POINT' do
    let(:esql) { Elastic::ESQL.from('sample_data') }

    it 'accepts just column' do
      esql.change_point('my_column')
      expect(esql.query).to eq 'FROM sample_data | CHANGE_POINT my_column'
    end

    it 'accepts key' do
      esql.change_point('my_column', key: 'my_key')
      expect(esql.query).to eq 'FROM sample_data | CHANGE_POINT my_column ON my_key'
    end

    it 'accepts key, type name and pvalue' do
      esql.change_point('my_column', key: 'my_key', type_name: 'spike', pvalue_name: 'pvalue')
      expect(esql.query).to eq 'FROM sample_data | CHANGE_POINT my_column ON my_key AS spike, pvalue'
    end
  end
end
