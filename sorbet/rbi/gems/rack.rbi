# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/rack/all/rack.rbi
#
# rack-3.1.4

module Rack
  def self.release; end
end
module Rack::Auth
end
class Rack::BodyProxy
  def close; end
  def closed?; end
  def initialize(body, &block); end
  def method_missing(method_name, *args, **, &block); end
  def respond_to_missing?(method_name, include_all = nil); end
end
class Rack::Cascade
  def <<(app); end
  def add(app); end
  def apps; end
  def call(env); end
  def include?(app); end
  def initialize(apps, cascade_for = nil); end
end