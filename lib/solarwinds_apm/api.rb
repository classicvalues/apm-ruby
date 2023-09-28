# Copyright (c) 2023 SolarWinds, LLC.
# All rights reserved.

require_relative './api/transaction_name'
require_relative './api/current_trace_info'
require_relative './api/tracing'
require_relative './api/opentelemetry'
require_relative './api/custom_metrics'

module SolarWindsAPM
  module API
    extend SolarWindsAPM::API::TransactionName
    extend SolarWindsAPM::API::CurrentTraceInfo
    extend SolarWindsAPM::API::Tracing
    extend SolarWindsAPM::API::OpenTelemetry
    extend SolarWindsAPM::API::CustomMetrics
  end
end