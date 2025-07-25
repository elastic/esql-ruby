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
  context 'LOOKUP JOIN' do
    let(:esql) { Elastic::ESQL.from('sample_data') }

    it 'accepts one lookup join' do
      esql.lookup_join!('threat_list', 'field_name')
      expect(esql.query).to eq 'FROM sample_data | LOOKUP JOIN threat_list ON field_name'
    end

    it 'accepts chained lookup joins' do
      esql.lookup_join!('threat_list', 'field_name')
          .lookup_join!('host_inventory', 'host.name')
          .lookup_join!('ownerships', 'host.name')
      expect(esql.query).to eq 'FROM sample_data | LOOKUP JOIN threat_list ON field_name | ' \
                               'LOOKUP JOIN host_inventory ON host.name | ' \
                               'LOOKUP JOIN ownerships ON host.name'
    end

    it 'does not mutate when using lookup_join' do
      expect(esql.lookup_join('threat_list', 'field_name').object_id).not_to eq esql.object_id
    end
  end
end
