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
  context 'SAMPLE' do
    let(:esql) { ESQL.from('employees') }

    it 'builds the query' do
      expect(
        esql.keep('emp_no').sample(0.05).query
      ).to eq(
        'FROM employees ' \
        '| KEEP emp_no ' \
        '| SAMPLE 0.05'
      )
    end

    it 'raises an error if probability not between 0 and 1' do
      expect do
        esql.keep('emp_no').sample(1.2).query
      end.to raise_error ArgumentError
    end
  end
end
