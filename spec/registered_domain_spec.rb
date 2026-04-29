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
  context 'REGISTERED_DOMAIN' do
    it 'builds a query with row' do
      esql = ESQL.row(fqdn: 'www.example.co.uk')
                 .registered_domain('rd', 'fqdn')
                 .keep('rd.*')
      expect(esql.query).to eq 'ROW fqdn = "www.example.co.uk" ' \
                               '| REGISTERED_DOMAIN rd = fqdn ' \
                               '| KEEP rd.*'
    end

    it 'builds a query with from' do
      esql = ESQL.from('web_logs')
                 .registered_domain('rd', 'domain')
                 .where('rd.registered_domain == "elastic.co"')
                 .stats(count: '*')
                 .by('rd.subdomain')
      expect(esql.query).to eq 'FROM web_logs ' \
                               '| REGISTERED_DOMAIN rd = domain ' \
                               '| WHERE rd.registered_domain == "elastic.co" ' \
                               '| STATS COUNT(*) BY rd.subdomain'
    end

    it 'uses the mutating option' do
      esql = ESQL.from('web_logs')
      esql.registered_domain!('rd', 'domain')
      expect(esql.query).to eq 'FROM web_logs | REGISTERED_DOMAIN rd = domain'
    end
  end
end
# rubocop:enable Metrics/BlockLength
