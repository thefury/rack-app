require 'uri'
require 'rack/app'
module Rack::App::Test

  def self.included(klass)
    klass.__send__(:extend,SpecHelpers)
  end

  module SpecHelpers

    def rack_app(*args,&constructor)

      begin
        let(:rack_app){ rack_app_by(*args,&constructor) }
      rescue NoMethodError
        define_method(:rack_app) do
          rack_app_by(*args,&constructor)
        end
      end

    end

  end

  def rack_app_by(*args,&constructor)
    subject_app = nil
    rack_app_class = args.shift

    if constructor.nil?
      subject_app = rack_app_class
    else
      subject_app = Class.new(rack_app_class || Rack::App)
      subject_app.class_eval(&constructor)
    end

    subject_app
  end

  [:get, :post, :put, :delete, :options, :patch].each do |request_method|
    define_method(request_method) do |properties|
      properties ||= Hash.new
      url = properties.delete(:url)
      request_env = request_env_by(request_method, url, properties)
      rack_app.call(request_env).last
    end
  end

  def format_properties(properties)
    raise('use hash format such as params: {"key" => "value"} or headers with the same concept') unless properties.is_a?(Hash)
    properties[:params] ||= {}
    properties[:headers]||= {}

    properties
  end

  def request_env_by(request_method, url, raw_properties)

    properties = format_properties(raw_properties)
    additional_headers = properties[:headers].reduce({}) { |m, (k, v)| m.merge("HTTP_#{k.to_s.gsub('-', '_').upcase}" => v.to_s) }

    payload = raw_properties.delete(:payload)
    additional_headers["rack.input"]= ::Rack::Lint::InputWrapper.new(StringIO.new(payload.to_s)) if payload.is_a?(String)

    {
        "REMOTE_ADDR" => "192.168.56.1",
        "REQUEST_METHOD" => request_method.to_s.upcase,
        "REQUEST_PATH" => url,
        "REQUEST_URI" => url,
        "SERVER_PROTOCOL" => "HTTP/1.1",
        "CONTENT_LENGTH" => "0",
        "CONTENT_TYPE" => "application/x-www-form-urlencoded",
        "SERVER_NAME" => "hds-dev.ett.local",
        "SERVER_PORT" => "80",
        "QUERY_STRING" => encode_www_form(properties[:params].to_a),
        "HTTP_VERSION" => "HTTP/1.1",
        "HTTP_USER_AGENT" => "spec",
        "HTTP_HOST" => "spec.local",
        "HTTP_ACCEPT_ENCODING" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "HTTP_ACCEPT" => "*/*",
        "HTTP_CONNECTION" => "close"
    }.merge(additional_headers)

  end

  def encode_www_form(enum)
    enum.map do |k, v|
      if v.nil?
        encode_www_form_component(k)
      elsif v.respond_to?(:to_ary)
        v.to_ary.map do |w|
          str = encode_www_form_component(k)
          unless w.nil?
            str << '='
            str << encode_www_form_component(w)
          end
        end.join('&')
      else
        str = encode_www_form_component(k)
        str << '='
        str << encode_www_form_component(v)
      end
    end.join('&')
  end

  TBLENCWWWCOMP_ = {} # :nodoc:
  256.times do |i|
    TBLENCWWWCOMP_['%%%02X' % i] = i.chr
  end
  TBLENCWWWCOMP_[' '] = '+'
  TBLENCWWWCOMP_.freeze
  TBLDECWWWCOMP = {} # :nodoc:
  256.times do |i|
    h, l = i>>4, i&15
    TBLDECWWWCOMP[i.chr]= '%%%X%X' % [h, l]
    TBLDECWWWCOMP[i.chr]= '%%%X%X' % [h, l]
    TBLDECWWWCOMP[i.chr]= '%%%x%X' % [h, l]
    TBLDECWWWCOMP[i.chr]= '%%%X%x' % [h, l]
    TBLDECWWWCOMP[i.chr]= '%%%x%x' % [h, l]
  end
  TBLDECWWWCOMP['+'] = ' '
  TBLDECWWWCOMP.freeze

  def encode_www_form_component(str)
    str = str.to_s.dup

    TBLENCWWWCOMP_.each do |from,to|
      str.gsub!(from,to)
    end
    str
  end

end