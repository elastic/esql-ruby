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
  context 'Custom String' do
    let(:esql) { ESQL.from('sample_data') }

    it 'accepts a custom string as a parameter' do
      esql.custom!('| MY_VALUE = "test value"')
      expect(esql.query).to eq 'FROM sample_data | MY_VALUE = "test value"'
    end

    it 'accepts chaining custom strings' do
      esql.custom!('| MY_VALUE = "test value"').custom!('| ANOTHER, VALUE')
      expect(esql.query).to eq 'FROM sample_data | MY_VALUE = "test value" | ANOTHER, VALUE'
    end

    it 'accepts a custom string as a parameter' do
      expect(esql.custom('| MY_VALUE = "test value"').to_s).to eq 'FROM sample_data | MY_VALUE = "test value"'
      expect(esql.query).to eq 'FROM sample_data'
    end

    it 'accepts chaining custom strings with `custom`' do
      expect(
        esql.custom('| MY_VALUE = "test value"').custom('| ANOTHER, VALUE').to_s
      ).to eq 'FROM sample_data | MY_VALUE = "test value" | ANOTHER, VALUE'
    end

    it 'does not mutate the original object when using `custom`' do
      expect(
        esql.custom('| MY_VALUE = "test value"').custom('| ANOTHER, VALUE').object_id
      ).not_to eq esql.object_id
    end
  end
end
