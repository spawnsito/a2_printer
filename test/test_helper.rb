require "minitest/autorun"
require "rubygems"
require "bundler"
require "mocha/test_unit"
Bundler.require(:default, :test)

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

class TestConnection
  attr_reader :bytes
  def initialize
    @bytes = []
  end

  def putc(byte)
    @bytes << byte
  end

  def write_bytes(*bytes)
    bytes.each { |b| putc(b) }
  end
end
