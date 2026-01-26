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
describe 'Docs examples' do
  context 'Extract data from unstructured text with DISSECT and GROK' do
    # Source: https://www.elastic.co/docs/reference/query-languages/esql/esql-process-data-with-dissect-grok
    it 'builds the DISSECT GROK queries' do
      expect(
        ESQL.row(a: '2023-01-23T12:15:00.000Z - some text - 127.0.0.1')
          .dissect('a', '%{date} - %{msg} - %{ip}')
          .keep('date', 'msg', 'ip')
          .eval(date: 'TO_DATETIME(date)')
          .query
      ).to eq(
        'ROW a = "2023-01-23T12:15:00.000Z - some text - 127.0.0.1" ' \
        '| DISSECT a """%{date} - %{msg} - %{ip}""" ' \
        '| KEEP date, msg, ip ' \
        '| EVAL date = TO_DATETIME(date)'
      )

      expect(
        ESQL.row(message: '[1998-08-10T17:15:42]          [WARN]')
          .dissect('message', '[%{ts}]%{->}[%{level}]')
          .to_s
      ).to eq(
        'ROW message = "[1998-08-10T17:15:42]          [WARN]" '\
        '| DISSECT message """[%{ts}]%{->}[%{level}]"""'
      )

      expect(
        ESQL.row(message: 'john jacob jingleheimer schmidt')
          .dissect('message', '%{+name} %{+name} %{+name} %{+name}', ' ')
          .to_s
      ).to eq(
        'ROW message = "john jacob jingleheimer schmidt" ' \
        '| DISSECT message """%{+name} %{+name} %{+name} %{+name}""" APPEND_SEPARATOR=" "'
      )

      expect(
        ESQL.row(message: 'john jacob jingleheimer schmidt')
          .dissect('message', '%{+name/2} %{+name/4} %{+name/3} %{+name/1}', ',')
          .to_s
      ).to eq(
        'ROW message = "john jacob jingleheimer schmidt" ' \
        '| DISSECT message """%{+name/2} %{+name/4} %{+name/3} %{+name/1}""" APPEND_SEPARATOR=","'
      )

      expect(
        ESQL.row(a: '2023-01-23T12:15:00.000Z 127.0.0.1 some.email@foo.com 42')
          .grok('a', '%{TIMESTAMP_ISO8601:date} %{IP:ip} %{EMAILADDRESS:email} %{NUMBER:num:int}')
          .keep('date, ip, email, num')
          .eval(date: 'TO_DATETIME(date)')
          .to_s
      ).to eq(
        'ROW a = "2023-01-23T12:15:00.000Z 127.0.0.1 some.email@foo.com 42" ' \
        '| GROK a """%{TIMESTAMP_ISO8601:date} %{IP:ip} %{EMAILADDRESS:email} %{NUMBER:num:int}""" ' \
        '| KEEP date, ip, email, num ' \
        '| EVAL date = TO_DATETIME(date)'
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
