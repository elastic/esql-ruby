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
  context 'MV_EXPAND' do
    let(:esql) { ESQL.row({ a: [1,2,3], b: "b", j: ["a","b"] }) }

    it 'builds the query' do
      esql.mv_expand!('a')
      expect(esql.query).to eq 'ROW a = [1, 2, 3], b = "b", j = ["a", "b"] | MV_EXPAND a'
    end

    it 'chains sort and limit' do
      esql.mv_expand!('a').sort!('b').limit!(10)
      expect(esql.query).to eq 'ROW a = [1, 2, 3], b = "b", j = ["a", "b"] | MV_EXPAND a | SORT b | LIMIT 10'
    end

    it 'uses the builder functions' do
      expect(
        esql.mv_expand('a').sort('b').limit(10).query
      ).to eq 'ROW a = [1, 2, 3], b = "b", j = ["a", "b"] | MV_EXPAND a | SORT b | LIMIT 10'
    end

    it 'does not change the object when using change_point' do
      expect(
        esql.mv_expand('a')
      ).not_to eq esql.object_id
      expect(esql.query).to eq 'ROW a = [1, 2, 3], b = "b", j = ["a", "b"]'
    end
  end
end
