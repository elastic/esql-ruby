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

module Elastic
  # The METRICS_INFO processing command retrieves information about the metrics available in time
  # series data streams, along with their applicable dimensions and other metadata.
  # Use METRICS_INFO to discover which metrics exist, what types and units they have, and which
  # dimensions apply to them without having to inspect index mappings or rely on the field
  # capabilities API. Any WHERE filters that precede METRICS_INFO narrow the set of time series
  # considered, so only metrics with matching data are returned.
  module MetricsInfo
    #
    # @example
    #   esql.ts('k8s').metric_info.sort('metric_name')
    # @see https://www.elastic.co/docs/reference/query-languages/esql/commands/metrics-info
    def metrics_info!
      @query[:metrics_info] = true
      self
    end

    def metrics_info
      esql = clone
      esql.instance_variable_set('@query', esql.instance_variable_get('@query').clone)
      esql.metrics_info!
      esql
    end
  end
end
