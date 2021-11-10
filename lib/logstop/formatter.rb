require "logger"

module Logstop
  class Formatter < ::Logger::Formatter
    attr_reader :formatter, :email, :phone, :ip, :scrubber

    def initialize(formatter = nil, email: true, phone: true, ip: false, scrubber: nil)
      @formatter = formatter || ::Logger::Formatter.new
      @email = email
      @phone = phone
      @ip = ip
      @scrubber = scrubber
    end

    def call(severity, timestamp, progname, msg)
      Logstop.scrub(
        formatter.call(severity, timestamp, progname, msg),
        email: email, phone: phone, ip: ip, scrubber: scrubber
      )
    end

    # for tagged logging
    def method_missing(method_name, *arguments, &block)
      @formatter.send(method_name, *arguments, &block)
    end

    # for tagged logging
    def respond_to?(method_name, include_private = false)
      @formatter.send(:respond_to?, method_name, include_private) || super
    end
  end
end
