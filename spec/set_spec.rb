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
  context 'SET' do
    let(:esql) { ESQL.from('many_numbers') }

    it 'Builds a query with SET' do
      esql.set({ approximation: true })
      expect(esql.query).to eq "SET approximation = true;\nFROM many_numbers"
    end

    it 'Builds a query passing in a Hash as value' do
      esql.set({ approximation: { rows: 10_000 } })
      expect(esql.query).to eq "SET approximation = {\"rows\":10000};\n" \
                               'FROM many_numbers'
    end

    it 'Builds a query passing in a String as value' do
      esql.set({ time_zone: '+05:00' })
      expect(esql.query).to eq "SET time_zone = \"+05:00\";\n" \
                               'FROM many_numbers'
    end

    it 'Concatenates multiple SET directives' do
      esql.set({ time_zone: '+05:00', approximation: true })
      expect(esql.query).to eq "SET time_zone = \"+05:00\", approximation = true;\n" \
                               'FROM many_numbers'
    end
  end
end
