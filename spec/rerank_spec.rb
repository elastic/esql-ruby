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
  context 'RERANK' do
    let(:esql) { ESQL.from('books') }

    it 'builds the query' do
      expect(
        esql.rerank(query: 'Tolkien')
            .on(['title', 'description'])
            .with('test_reranker')
            .query
      ).to eq 'FROM books | ' \
              'RERANK "Tolkien" ' \
              'ON title, description ' \
              'WITH { "inference_id" : "test_reranker" }'
    end

    it 'builds an example query' do
      query = esql.metadata('_score')
                  .where('MATCH(description, "hobbit") OR MATCH(author, "Tolkien")')
                  .sort('_score')
                  .desc
                  .limit(100)
                  .rerank(column: 'rerank_score', query: 'hobbit')
                  .on(['description', 'author'])
                  .with('test_reranker')
      expect(query.query).to eq(
        'FROM books METADATA _score ' \
        '| WHERE MATCH(description, "hobbit") OR MATCH(author, "Tolkien") ' \
        '| SORT _score DESC ' \
        '| LIMIT 100 ' \
        '| RERANK rerank_score = "hobbit" ' \
        'ON description, author ' \
        'WITH { "inference_id" : "test_reranker" }' \
      )
    end

    it 'builds another example query' do
      query = esql.metadata('_score')
                  .where('MATCH(description, "hobbit") OR MATCH(author, "Tolkien")')
                  .sort('_score')
                  .desc
                  .limit(100)
                  .rerank(column: 'rerank_score', query: 'hobbit')
                  .on(['description', 'author'])
                  .with('test_reranker')
                  .sort('rerank_score').desc
                  .sort('book_no').desc
                  .limit(3)
      expect(query.query).to eq(
        'FROM books METADATA _score ' \
        '| WHERE MATCH(description, "hobbit") OR MATCH(author, "Tolkien") ' \
        '| SORT _score DESC ' \
        '| LIMIT 100 ' \
        '| RERANK rerank_score = "hobbit" ON description, author WITH { "inference_id" : "test_reranker" } ' \
        '| SORT rerank_score DESC, book_no DESC ' \
        '| LIMIT 3'
      )
    end

    it 'builds another example query' do
      query = esql.metadata('_score')
                  .where('MATCH(description, "hobbit")')
                  .sort('_score')
                  .desc
                  .limit(100)
                  .rerank(query: 'hobbit')
                  .on('description')
                  .with('test_reranker')
                  .limit(3)
                  .keep('title', '_score')
      expect(query.query).to eq(
        'FROM books METADATA _score ' \
        '| WHERE MATCH(description, "hobbit") ' \
        '| SORT _score DESC ' \
        '| LIMIT 100 ' \
        '| RERANK "hobbit" ON description WITH { "inference_id" : "test_reranker" } ' \
        '| LIMIT 3 ' \
        '| KEEP title, _score'
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
