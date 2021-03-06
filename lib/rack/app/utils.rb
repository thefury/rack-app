require 'securerandom'
module Rack::App::Utils
  extend self

  # Normalizes URI path.
  #
  # Strips off trailing slash and ensures there is a leading slash.
  #
  #   normalize_path("/foo")  # => "/foo"
  #   normalize_path("/foo/") # => "/foo"
  #   normalize_path("foo")   # => "/foo"
  #   normalize_path("")      # => "/"
  def normalize_path(path)
    path = "/#{path}"
    path.squeeze!('/')
    path.sub!(%r{/+\Z}, '')
    path = '/' if path == ''
    path
  end

  def pwd(*path_parts)

    root_folder =if ENV['BUNDLE_GEMFILE']
                   ENV['BUNDLE_GEMFILE'].split(File::Separator)[0..-2].join(File::Separator)
                 else
                   Dir.pwd.to_s
                 end

    return File.join(root_folder,*path_parts)

  end

  def uuid
    ary = SecureRandom.random_bytes(16).unpack("NnnnnN")
    ary[2] = (ary[2] & 0x0fff) | 0x4000
    ary[3] = (ary[3] & 0x3fff) | 0x8000
    "%08x-%04x-%04x-%04x-%04x%08x" % ary
  end

end