# Copyright (c) 2019 SolarWinds, LLC.
# All rights reserved.

require 'minitest_helper'

describe 'OboeInitOptions' do

  before do
    @env = ENV.to_hash
    # lets suppress logging, because we will log a lot of errors when testing the service_key
    @log_level = SolarWindsOTelAPM.logger.level
    SolarWindsOTelAPM.logger.level = 6

    ENV.delete('SW_APM_SERVICE_KEY')
    ENV.delete('OTEL_SERVICE_NAME')
    ENV.delete('OTEL_RESOURCE_ATTRIBUTES')
    ENV.delete('SW_APM_REPORTER')
    SolarWindsOTelAPM::Config[:service_key]       = nil
    SolarWindsOTelAPM::Config[:otel_service_name] = nil
  end

  after do
    @env.each { |k, v| ENV[k] = v }
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    SolarWindsOTelAPM.logger.level = @log_level
  end

  it 'sets all options from ENV vars' do
    ENV.delete('SW_APM_GEM_TEST')

    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:test_app'
    ENV['SW_APM_REPORTER'] = 'ssl'
    ENV['SW_APM_COLLECTOR'] = 'string_2'
    ENV['SW_APM_TRUSTEDPATH'] = 'string_3'
    ENV['SW_APM_HOSTNAME_ALIAS'] = 'string_4'
    ENV['SW_APM_BUFSIZE'] = '11'
    ENV['SW_APM_LOGFILE'] = 'string_5'
    ENV['SW_APM_DEBUG_LEVEL'] = '2'
    ENV['SW_APM_TRACE_METRICS'] = '3'
    ENV['SW_APM_HISTOGRAM_PRECISION'] = '4'
    ENV['SW_APM_MAX_TRANSACTIONS'] = '5'
    ENV['SW_APM_FLUSH_MAX_WAIT_TIME'] = '6'
    ENV['SW_APM_EVENTS_FLUSH_INTERVAL'] = '7'
    ENV['SW_APM_EVENTS_FLUSH_BATCH_SIZE'] = '8'
    ENV['SW_APM_TOKEN_BUCKET_CAPACITY'] = '9'
    ENV['SW_APM_TOKEN_BUCKET_RATE'] = '10'
    ENV['SW_APM_REPORTER_FILE_SINGLE'] = 'True'
    ENV['SW_APM_EC2_METADATA_TIMEOUT'] = '1234'
    ENV['SW_APM_PROXY'] = 'http://the.proxy:1234'

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    options = SolarWindsOTelAPM::OboeInitOptions.instance.array_for_oboe

    _(options.size).must_equal 21
    _(options[0]).must_equal 'string_4'
    _(options[1]).must_equal 2
    _(options[2]).must_equal 'string_5'
    _(options[3]).must_equal 5
    _(options[4]).must_equal 6
    _(options[5]).must_equal 7
    _(options[6]).must_equal 8
    _(options[7]).must_equal 'ssl'
    _(options[8]).must_equal 'string_2'
    _(options[9]).must_equal 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:test_app'
    _(options[10]).must_equal ''
    _(options[11]).must_equal 11
    _(options[12]).must_equal 3
    _(options[13]).must_equal 4
    _(options[14]).must_equal 9
    _(options[15]).must_equal 10
    _(options[16]).must_equal 1
    _(options[17]).must_equal 1234
    _(options[18]).must_equal 'http://the.proxy:1234'
    _(options[20]).must_equal 0
  end

  it 'env vars override config vars' do
    ENV.delete('SW_APM_GEM_TEST')
    ENV['SW_APM_REPORTER'] = 'ssl'

    ENV['SW_APM_HOSTNAME_ALIAS'] = 'string_0'
    ENV['SW_APM_DEBUG_LEVEL'] = '1'
    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:test_app'
    ENV['SW_APM_EC2_METADATA_TIMEOUT'] = '1212'
    ENV['SW_APM_PROXY'] = 'http://the.proxy:2222'

    SolarWindsOTelAPM::Config[:hostname_alias] = 'string_2'
    SolarWindsOTelAPM::Config[:debug_level] = 2
    SolarWindsOTelAPM::Config[:service_key] = 'string_3'
    SolarWindsOTelAPM::Config[:ec2_metadata_timeout] = 2323
    SolarWindsOTelAPM::Config[:http_proxy] = 'http://the.proxy:7777'

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    options = SolarWindsOTelAPM::OboeInitOptions.instance.array_for_oboe

    _(options.size).must_equal 21

    _(options[0]).must_equal 'string_0'
    _(options[1]).must_equal 1
    _(options[9]).must_equal 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:test_app'
    _(options[17]).must_equal 1212
    _(options[18]).must_equal 'http://the.proxy:2222'
  end

  it 'checks for metric mode appoptics' do
    ENV.delete('SW_APM_COLLECTOR')
    ENV['SW_APM_COLLECTOR'] = 'collector.abc.bbc.appoptics.com'

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    options = SolarWindsOTelAPM::OboeInitOptions.instance.array_for_oboe

    _(options.size).must_equal 21
    _(options[20]).must_equal 0
  end

  it 'checks for metric mode nighthawk' do
    ENV.delete('SW_APM_COLLECTOR')
    ENV['SW_APM_COLLECTOR'] = 'collector.abc.bbc.solarwinds.com'
    
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    options = SolarWindsOTelAPM::OboeInitOptions.instance.array_for_oboe

    _(options.size).must_equal 21
    _(options[20]).must_equal 0
  end

  it 'checks for metric mode default' do
    ENV.delete('SW_APM_COLLECTOR')
    ENV['SW_APM_COLLECTOR'] = 'www.google.ca'
    
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    options = SolarWindsOTelAPM::OboeInitOptions.instance.array_for_oboe

    _(options.size).must_equal 21
    _(options[20]).must_equal 0
  end

  it 'checks for metric mode when sw_apm_collector is nil' do
    ENV.delete('SW_APM_COLLECTOR')
    
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    options = SolarWindsOTelAPM::OboeInitOptions.instance.array_for_oboe

    _(options.size).must_equal 21
    _(options[20]).must_equal 0
  end

  it 'checks for default certificates for ao' do
    ENV.delete('SW_APM_TRUSTEDPATH')
    ENV.delete('SW_APM_COLLECTOR')
    ENV["SW_APM_COLLECTOR"] = 'collector.appoptics.com'

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    options = SolarWindsOTelAPM::OboeInitOptions.instance.array_for_oboe

    _(options.size).must_equal 21
    _(options[10]).must_equal "-----BEGIN CERTIFICATE-----\nMIID8TCCAtmgAwIBAgIJAMoDz7Npas2/MA0GCSqGSIb3DQEBCwUAMIGOMQswCQYD\nVQQGEwJVUzETMBEGA1UECAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5j\naXNjbzEVMBMGA1UECgwMTGlicmF0byBJbmMuMRUwEwYDVQQDDAxBcHBPcHRpY3Mg\nQ0ExJDAiBgkqhkiG9w0BCQEWFXN1cHBvcnRAYXBwb3B0aWNzLmNvbTAeFw0xNzA5\nMTUyMjAxMzlaFw0yNzA5MTMyMjAxMzlaMIGOMQswCQYDVQQGEwJVUzETMBEGA1UE\nCAwKQ2FsaWZvcm5pYTEWMBQGA1UEBwwNU2FuIEZyYW5jaXNjbzEVMBMGA1UECgwM\nTGlicmF0byBJbmMuMRUwEwYDVQQDDAxBcHBPcHRpY3MgQ0ExJDAiBgkqhkiG9w0B\nCQEWFXN1cHBvcnRAYXBwb3B0aWNzLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEP\nADCCAQoCggEBAOxO0wsGba3iI4r3L5BMST0rAO/gGaUhpQre6nRwVTmPCnLw1bmn\nGdiFgYv/oRRwU+VieumHSQqoOmyFrg+ajGmvUDp2WqQ0It+XhcbaHFiAp2H7+mLf\ncUH6S43/em0WUxZHeRzRupRDyO1bX6Hh2jgxykivlFrn5HCIQD5Hx1/SaZoW9v2n\noATCbgFOiPW6kU/AVs4R0VBujon13HCehVelNKkazrAEBT1i6RvdOB6aQQ32seW+\ngLV5yVWSPEJvA9ZJqad/nQ8EQUMSSlVN191WOjp4bGpkJE1svs7NmM+Oja50W56l\nqOH5eWermr/8qWjdPlDJ+I0VkgN0UyHVuRECAwEAAaNQME4wHQYDVR0OBBYEFOuL\nKDTFhRQXwlBRxhPqhukrNYeRMB8GA1UdIwQYMBaAFOuLKDTFhRQXwlBRxhPqhukr\nNYeRMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAJQtH446NZhjusy6\niCyvmnD95ybfNPDpjHmNx5n9Y6w9n+9y1o3732HUJE+WjvbLS3h1o7wujGKMcRJn\n7I7eTDd26ZhLvnh5/AitYjdxrtUkQDgyxwLFJKhZu0ik2vXqj0fL961/quJL8Gyp\nhNj3Nf7WMohQMSohEmCCX2sHyZGVGYmQHs5omAtkH/NNySqmsWNcpgd3M0aPDRBZ\n5VFreOSGKBTJnoLNqods/S9RV0by84hm3j6aQ/tMDIVE9VCJtrE6evzC0MWyVFwR\nftgwcxyEq5SkiR+6BCwdzAMqADV37TzXDHLjwSrMIrgLV5xZM20Kk6chxI5QAr/f\n7tsqAxw=\n-----END CERTIFICATE-----"
  end

  it 'checks for default certificates for swo' do
    ENV.delete('SW_APM_TRUSTEDPATH')
    ENV.delete('SW_APM_COLLECTOR')
    ENV["SW_APM_COLLECTOR"] = 'collector.abc.bbc.solarwinds.com'
    
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    options = SolarWindsOTelAPM::OboeInitOptions.instance.array_for_oboe

    _(options.size).must_equal 21
    _(options[10]).must_equal ""
  end

  it 'checks for customized certificates' do
    ENV.delete('SW_APM_TRUSTEDPATH')
    ENV['SW_APM_TRUSTEDPATH'] = "#{File.expand_path __dir__}/tmp.cert"

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    options = SolarWindsOTelAPM::OboeInitOptions.instance.array_for_oboe

    _(options.size).must_equal 21
    _(options[10]).must_equal "-----BEGIN CERTIFICATE-----\nMIID8TCCAtmgAwIBAgIJAMoDz7Npas2/MA0GCSqGSIb3DQEBCwUAMIGOMQswCQYD\n-----END CERTIFICATE-----"
  end

  it 'checks the service_key for ssl' do
    ENV.delete('SW_APM_GEM_TEST')
    ENV['SW_APM_REPORTER'] = 'ssl'
    ENV['SW_APM_SERVICE_KEY'] = 'string_0'

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal false

    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:test_app'

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal true
  end

  it 'returns true for the service_key check for other reporters' do
    ENV.delete('SW_APM_GEM_TEST')
    ENV['SW_APM_REPORTER'] = 'udp'
    ENV['SW_APM_SERVICE_KEY'] = 'string_0'

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal true

    ENV['SW_APM_REPORTER'] = 'file'

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal true

    ENV['SW_APM_REPORTER'] = 'null'

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal true
  end

  it 'validates the service key' do
    ENV.delete('SW_APM_GEM_TEST')
    ENV['SW_APM_REPORTER'] = 'ssl'
    ENV['SW_APM_SERVICE_KEY'] = nil
    SolarWindsOTelAPM::Config[:service_key] = nil

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal false

    SolarWindsOTelAPM::Config[:service_key] = '22222222-2222-2222-2222-222222222222:service'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal false

    SolarWindsOTelAPM::Config[:service_key] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal false

    SolarWindsOTelAPM::Config[:service_key] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal false

    SolarWindsOTelAPM::Config[:service_key] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:service'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal true

    SolarWindsOTelAPM::Config[:service_key] = nil
    
    ENV['SW_APM_SERVICE_KEY'] = 'blabla'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal false

    ENV['SW_APM_SERVICE_KEY'] = nil
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal false

    ENV['SW_APM_SERVICE_KEY'] = '22222222-2222-2222-2222-222222222222:service'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal false

    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal false

    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal false

    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:service'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal true
  end

  it 'removes invalid characters from the service name' do
    ENV.delete('SW_APM_GEM_TEST')
    ENV['SW_APM_REPORTER'] = 'ssl'
    ENV['SW_APM_SERVICE_KEY'] = 'f7B-kZXtk1sxaJGkv-wew1244444444444444444444444IptKFVPRv0o8keDro9QbKioW4:service#####.:-_0'

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal true
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_name).must_equal 'service.:-_0'
  end

  it 'transforms the service name to lower case' do
    ENV.delete('SW_APM_GEM_TEST')
    ENV['SW_APM_REPORTER'] = 'ssl'
    ENV['SW_APM_SERVICE_KEY'] = 'f7B-kZXtk1sxaJGkv-wew1244444444444444444444444IptKFVPRv0o8keDro9QbKioW4:SERVICE#####.:-_0'

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal true
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_name).must_equal 'service.:-_0'
  end

  it 'shortens the service name to 255 characters' do
    ENV.delete('SW_APM_GEM_TEST')
    ENV['SW_APM_REPORTER'] = 'ssl'
    ENV['SW_APM_SERVICE_KEY'] = "f7B-kZXtk1sxaJGkv-wew1244444444444444444444444IptKFVPRv0o8keDro9QbKioW4:SERV#_#{'1234567890' * 26}"

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal true
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_name).must_equal "serv_#{'1234567890' * 25}"
  end

  it 'replaces invalid ec2 metadata timeouts with the default' do
    ENV['SW_APM_EC2_METADATA_TIMEOUT'] = '-12'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.ec2_md_timeout).must_equal 1000

    ENV['SW_APM_EC2_METADATA_TIMEOUT'] = '3001'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.ec2_md_timeout).must_equal 1000

    ENV['SW_APM_EC2_METADATA_TIMEOUT'] = 'qoieurqopityeoritbweortmvoiu'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.ec2_md_timeout).must_equal 1000
  end

  it 'rejects invalid proxy strings' do
    ENV['SW_APM_PROXY'] = ''

    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.grpc_proxy).must_equal ''

    ENV['SW_APM_PROXY'] = 'qoieurqopityeoritbweortmvoiu'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.grpc_proxy).must_equal ''

    ENV['SW_APM_PROXY'] = 'https://sgdgsdg:4000'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.grpc_proxy).must_equal ''

    ENV['SW_APM_PROXY'] = 'http://sgdgsdg'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.grpc_proxy).must_equal ''
  end

  it 'rejects invalid collector string' do
    ENV['SW_APM_COLLECTOR'] = 'collector.appoptics.com:443'
    is_appoptics = SolarWindsOTelAPM::OboeInitOptions.instance.send(:appoptics_collector?)
    _(is_appoptics).must_equal true

    ENV['SW_APM_COLLECTOR'] = 'collector.appoptics.com'
    is_appoptics = SolarWindsOTelAPM::OboeInitOptions.instance.send(:appoptics_collector?)
    _(is_appoptics).must_equal true

    ENV['SW_APM_COLLECTOR'] = 'puts"abc".appoptics.com'
    is_appoptics = SolarWindsOTelAPM::OboeInitOptions.instance.send(:appoptics_collector?)
    _(is_appoptics).must_equal false

    ENV['SW_APM_COLLECTOR'] = '\xA4\xA49\x9D\xAC\xA5\x98\xC1.appoptics.com'
    is_appoptics = SolarWindsOTelAPM::OboeInitOptions.instance.send(:appoptics_collector?)
    _(is_appoptics).must_equal false

    ENV['SW_APM_COLLECTOR'] = 'google.ca.appoptics'
    is_appoptics = SolarWindsOTelAPM::OboeInitOptions.instance.send(:appoptics_collector?)
    _(is_appoptics).must_equal false
  end

  it 'sanitze uri for collector uri' do
    uri = 'collector.appoptics.com:443'
    sanitized_uri = SolarWindsOTelAPM::OboeInitOptions.instance.send(:sanitize_collector_uri, uri)
    _(sanitized_uri).must_equal 'collector.appoptics.com'

    uri = 'collector.appoptics.com'
    sanitized_uri = SolarWindsOTelAPM::OboeInitOptions.instance.send(:sanitize_collector_uri, uri)
    _(sanitized_uri).must_equal 'collector.appoptics.com'

    uri = 'puts"abc".appoptics.com'
    sanitized_uri = SolarWindsOTelAPM::OboeInitOptions.instance.send(:sanitize_collector_uri, uri)
    _(sanitized_uri).must_equal ""

    uri = '\xA4\xA49\x9D\xAC\xA5\x98\xC1.appoptics.com'
    sanitized_uri = SolarWindsOTelAPM::OboeInitOptions.instance.send(:sanitize_collector_uri, uri)
    _(sanitized_uri).must_equal ""

    uri = 'google.ca.appoptics'
    sanitized_uri = SolarWindsOTelAPM::OboeInitOptions.instance.send(:sanitize_collector_uri, uri)
    _(sanitized_uri).must_equal "google.ca.appoptics"
  end

  it 'test when otel_service_name exist' do
    ENV['SW_APM_REPORTER'] = 'ssl'
    ENV['OTEL_SERVICE_NAME'] = 'abcdef'
    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:my-cool-service'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal true
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_name).must_equal 'abcdef'

    ENV['OTEL_SERVICE_NAME'] = nil
    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:my-cool-service'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal true
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_name).must_equal 'my-cool-service'

    ENV['OTEL_SERVICE_NAME']  = ""
    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:my-cool-service'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_key_ok?).must_equal true
    _(SolarWindsOTelAPM::OboeInitOptions.instance.service_name).must_equal 'my-cool-service'
  end

  it 'test when otel_service_name does not exist' do
    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:my-cool-service'
    ENV['OTEL_SERVICE_NAME']  = nil
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(ENV['OTEL_SERVICE_NAME']).must_equal 'my-cool-service'

    ENV['OTEL_SERVICE_NAME']  = nil
    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(ENV['OTEL_SERVICE_NAME']).must_equal nil

    ENV['OTEL_SERVICE_NAME']  = nil
    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(ENV['OTEL_SERVICE_NAME']).must_equal nil

  end

  it 'test_with_OTEL_RESOURCE_ATTRIBUTES_and_OTEL_SERVICE_NAME' do
    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:my-cool-service'
    ENV['OTEL_SERVICE_NAME']  = nil
    ENV['OTEL_RESOURCE_ATTRIBUTES'] = 'service.name=my-chill-service'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(ENV['OTEL_SERVICE_NAME']).must_equal 'my-chill-service'

    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:my-cool-service'
    ENV['OTEL_SERVICE_NAME']  = 'my-service-name'
    ENV['OTEL_RESOURCE_ATTRIBUTES'] = 'service.name=my-chill-service'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(ENV['OTEL_SERVICE_NAME']).must_equal 'my-service-name'

    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:my-cool-service'
    ENV['OTEL_SERVICE_NAME']  = 'my-service-name'
    ENV['OTEL_RESOURCE_ATTRIBUTES'] = nil
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(ENV['OTEL_SERVICE_NAME']).must_equal 'my-service-name'

    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:my-cool-service'
    ENV['OTEL_SERVICE_NAME']  = nil
    ENV['OTEL_RESOURCE_ATTRIBUTES'] = nil
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(ENV['OTEL_SERVICE_NAME']).must_equal 'my-cool-service'

    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:'
    ENV['OTEL_SERVICE_NAME']  = nil
    ENV['OTEL_RESOURCE_ATTRIBUTES'] = nil
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(ENV['OTEL_SERVICE_NAME']).must_equal nil

    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:'
    ENV['OTEL_SERVICE_NAME']  = 'my-cool-service'
    ENV['OTEL_RESOURCE_ATTRIBUTES'] = nil
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(ENV['OTEL_SERVICE_NAME']).must_equal nil

    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:'
    ENV['OTEL_SERVICE_NAME']  = nil
    ENV['OTEL_RESOURCE_ATTRIBUTES'] = 'service.name=my-chill-service'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(ENV['OTEL_SERVICE_NAME']).must_equal nil

    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq:'
    ENV['OTEL_SERVICE_NAME']  = 'my-cool-service'
    ENV['OTEL_RESOURCE_ATTRIBUTES'] = 'service.name=my-chill-service'
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(ENV['OTEL_SERVICE_NAME']).must_equal nil

    ENV['SW_APM_SERVICE_KEY'] = 'CWoadXY66FXNd_e5u3nabLZ1KByYZRTi1yWJg2AcD6MHo1AA42UstbipfHfx6Hnl-821ARq'
    ENV['OTEL_SERVICE_NAME']  = nil
    ENV['OTEL_RESOURCE_ATTRIBUTES'] = nil
    SolarWindsOTelAPM::OboeInitOptions.instance.re_init
    _(ENV['OTEL_SERVICE_NAME']).must_equal nil

  end
end