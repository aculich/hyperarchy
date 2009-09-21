dir = File.dirname(__FILE__)

class Object
  def jruby?
    defined? JRUBY_VERSION
  end
end


MONARCH_SERVER_ROOT = File.expand_path(File.join(dir, '..', '..'))
MONARCH_CLIENT_SERVER_ROOT = File.expand_path(File.join(MONARCH_SERVER_ROOT, 'client'))
MONARCH_SERVER_SERVER_ROOT = File.expand_path(File.join(MONARCH_SERVER_ROOT, 'server'))

require "rubygems"

if jruby?
  require "rack"
  require "#{dir}/monarch/monarch-1-jar-with-dependencies"
else
  require "thin"
end
require "sequel"
require "sequel/extensions/inflector"
require "guid"
require "json"
require "active_support/ordered_hash"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/hash/keys"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/string/starts_ends_with"

require "#{dir}/monarch/http"
require "#{dir}/monarch/model"
require "#{dir}/monarch/core_extensions"

class String
 include ActiveSupport::CoreExtensions::String::StartsEndsWith
end

class Hash
  include ActiveSupport::CoreExtensions::Hash::Keys
end

Origin = Model::RemoteRepository.new

MONARCH_ASSET_PREFIX = "" unless defined?(MONARCH_ASSET_PREFIX)
Http::AssetManager.add_js_location("#{MONARCH_ASSET_PREFIX}/monarch/lib", "#{MONARCH_CLIENT_SERVER_ROOT}/lib")
Http::AssetManager.add_js_location("#{MONARCH_ASSET_PREFIX}/monarch/vendor", "#{MONARCH_CLIENT_SERVER_ROOT}/vendor")
