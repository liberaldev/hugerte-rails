#
# Rails 4.2 and sprockets-rails 3.0.0 introduces behaviour whereby asset
# digests are enabled by default in development mode and any requests to
# undigested assets raise a NoDigestError.
#
# Since hugerte-rails uses undigested assets for dynamically loaded HugeRTE
# assets, we need to bypass this behaviour by returning an empty fingerprint
# for assets beneath hugerte/ that don't already have one.
#
# This module extends the Sprockets::Rails::Environment class defined at:
# https://github.com/rails/sprockets-rails/blob/master/lib/sprockets/rails/environment.rb
#
module HugeRTE::Rails::Environment
  def path_fingerprint(path)
    fingerprint = super
    return fingerprint if fingerprint
    return "" if path =~ /^hugerte\//
  end
end

Sprockets::Rails::Environment.class_eval do
  include HugeRTE::Rails::Environment
end
