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
  context 'EVAL' do
    let(:esql) { Elastic::ESQL.new('sample_data') }

    it 'accepts 2 strings as a parameter' do
      esql.eval('duration_ms', 'event_duration/10000.0')
      expect(esql.query).to eq 'FROM sample_data | EVAL duration_ms = event_duration/10000.0'
    end

    it 'accepts a Hash as a parameter' do
      esql.eval({ height_feet: 'height * 3.281', height_cm: 'height * 100' })
      expect(esql.query).to eq 'FROM sample_data | EVAL height_feet = height * 3.281, height_cm = height * 100'
    end

    it 'raises error if the parameters are wrong' do
      expect { esql.eval('duration_ms', 'event_duration', 1000) }.to raise_error ArgumentError
    end
  end
end
