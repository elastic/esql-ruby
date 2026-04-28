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
  context 'USER AGENT' do
    it 'builds a basic query' do
      expect(
        ESQL.row(input: 'Mozilla/5.0')
          .user_agent(ua: 'input')
          .keep('ua.*').query
      ).to eq 'ROW input = "Mozilla/5.0" ' \
              '| USER_AGENT ua = input ' \
              '| KEEP ua.*'
    end

    it 'builds a basic query using with' do
      expect(
        ESQL.row(input: 'Mozilla/5.0')
          .user_agent(ua: 'input')
          .with(extract_device_type: true)
          .keep('ua.*').query
      ).to eq 'ROW input = "Mozilla/5.0" ' \
              '| USER_AGENT ua = input WITH { "extract_device_type": true } ' \
              '| KEEP ua.*'
    end

    it 'builds the query with regex_file' do
      expect(
        ESQL.from('web_logs')
          .user_agent(ua: 'user_agent')
          .with(regex_file: 'my-regexes.yml')
          .keep('ua.name, ua.version').query
      ).to eq 'FROM web_logs ' \
              '| USER_AGENT ua = user_agent WITH { "regex_file": "my-regexes.yml" } ' \
              '| KEEP ua.name, ua.version'
    end

    it 'builds the query with regex_file' do
      expect(
        ESQL.row(ua_str: 'Mozilla/5.0 (X11; Linux x86_64; rv:150.0) Gecko/20100101 Firefox/150.0')
          .user_agent(ua: 'ua_str')
          .with(properties: ['name', 'version', 'device'], extract_device_type: true)
          .keep('ua.*').query
      ).to eq 'ROW ua_str = "Mozilla/5.0 (X11; Linux x86_64; rv:150.0) Gecko/20100101 Firefox/150.0" ' \
              '| USER_AGENT ua = ua_str ' \
              'WITH { "properties": ["name", "version", "device"], "extract_device_type": true } ' \
              '| KEEP ua.*'
    end
  end
end
# rubocop:enable Metrics/BlockLength
