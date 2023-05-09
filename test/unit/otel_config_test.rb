# Copyright (c) 2019 SolarWinds, LLC.
# All rights reserved.

require 'minitest_helper'

describe 'Loading Opentelemetry Test' do

  before do
    clean_old_setting
    SolarWindsOTelAPM::OTelConfig.class_variable_set(:@@agent_enabled, true)
    SolarWindsOTelAPM::OTelConfig.class_variable_set(:@@config, {})
    SolarWindsOTelAPM::OTelConfig.class_variable_set(:@@config_map, {})
    sleep 1
  end

  it 'default_response_propagators' do

    SolarWindsOTelAPM::OTelConfig.initialize
    rack_config = SolarWindsOTelAPM::OTelConfig.class_variable_get(:@@config_map)['OpenTelemetry::Instrumentation::Rack']
    _(rack_config.count).must_equal 1
    _(rack_config[:response_propagators][0].class).must_equal SolarWindsOTelAPM::OpenTelemetry::SolarWindsResponsePropagator::TextMapPropagator
  end

  it 'default_response_propagators_with_other_rack_config' do

    SolarWindsOTelAPM::OTelConfig.initialize do |config|
      config['OpenTelemetry::Instrumentation::Rack'] = {:record_frontend_span => true}
    end
    rack_config = SolarWindsOTelAPM::OTelConfig.class_variable_get(:@@config_map)['OpenTelemetry::Instrumentation::Rack']
    _(rack_config.count).must_equal 2
    _(rack_config[:record_frontend_span]).must_equal true
    _(rack_config[:response_propagators][0].class).must_equal SolarWindsOTelAPM::OpenTelemetry::SolarWindsResponsePropagator::TextMapPropagator
  end

  it 'default_response_propagators_with_other_response_propagators' do
    SolarWindsOTelAPM::OTelConfig.initialize do |config|
      config['OpenTelemetry::Instrumentation::Rack'] = {:response_propagators => ['String']}
    end
    rack_config = SolarWindsOTelAPM::OTelConfig.class_variable_get(:@@config_map)['OpenTelemetry::Instrumentation::Rack']
    _(rack_config.count).must_equal 1
    _(rack_config[:response_propagators].count).must_equal 2
    _(rack_config[:response_propagators][0]).must_equal 'String'
    _(rack_config[:response_propagators][1].class).must_equal SolarWindsOTelAPM::OpenTelemetry::SolarWindsResponsePropagator::TextMapPropagator
  end

  it 'default_response_propagators_with_non_array_response_propagators' do
    SolarWindsOTelAPM::OTelConfig.initialize do |config|
      config['OpenTelemetry::Instrumentation::Rack'] = {:response_propagators => 'String'}
    end
    rack_config = SolarWindsOTelAPM::OTelConfig.class_variable_get(:@@config_map)['OpenTelemetry::Instrumentation::Rack']
    _(rack_config.count).must_equal 1
    _(rack_config[:response_propagators].count).must_equal 1
    _(rack_config[:response_propagators][0].class).must_equal SolarWindsOTelAPM::OpenTelemetry::SolarWindsResponsePropagator::TextMapPropagator
  end

end
