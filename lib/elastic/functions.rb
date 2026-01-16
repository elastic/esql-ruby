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
  AGG_FUNCTIONS = [
    :absent,
    :avg,
    :count,
    :count_distinct,
    :max,
    :median,
    :median_absolute_deviation,
    :min,
    :percentile,
    :present,
    :sample,
    :st_centroid_agg,
    :st_extent_agg,
    :std_dev,
    :sum,
    :top,
    :values,
    :variance,
    :weighted_avg
  ].freeze

  TS_AGG_FUNCTIONS = [
    :absent_over_time,
    :avg_over_time,
    :count_over_time,
    :count_distinct_over_time,
    :delta,
    :deriv,
    :first_over_time,
    :idelta,
    :increase,
    :irate,
    :last_over_time,
    :max_over_time,
    :min_over_time,
    :percentile_over_time,
    :present_over_time,
    :rate,
    :stddev_over_time,
    :sum_over_time,
    :variance_over_time
  ].freeze
end
