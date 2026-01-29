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
  context 'FUSE' do
    let(:esql) do
      ESQL.from('books')
          .metadata('_id, _index, _score')
          .fork([
                  ESQL.branch.where('title == "Shakespeare"').sort('_score').desc,
                  ESQL.branch.where('semantic_title == "Shakespeare"').sort('_score').desc
                ])
    end

    it 'builds a fuse query with no parameters' do
      expect(esql.fuse.to_s).to eq(
        'FROM books METADATA _id, _index, _score ' \
        '| FORK (WHERE title == "Shakespeare" | SORT _score DESC) ' \
        '(WHERE semantic_title == "Shakespeare" | SORT _score DESC) ' \
        '| FUSE'
      )
    end

    it 'builds a fuse LINEAR query' do
      expect(esql.fuse(:linear).to_s).to eq(
        'FROM books METADATA _id, _index, _score ' \
        '| FORK (WHERE title == "Shakespeare" | SORT _score DESC) ' \
        '(WHERE semantic_title == "Shakespeare" | SORT _score DESC) ' \
        '| FUSE LINEAR'
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
