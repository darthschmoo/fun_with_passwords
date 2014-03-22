require 'rubygems'
require 'bundler'
require 'debugger'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'fun_with_passwords'

class Test::Unit::TestCase
end

class FunWith::Passwords::TestCase < Test::Unit::TestCase
  include FunWith::Passwords
  def tmpdir( &block )
    FunWith::Files::FilePath.tmpdir do |tmp|
      @tmpdir = tmp
      warn( "temporary dir not writable.  Some tests may fail." ) unless @tmpdir.directory? && @tmpdir.writable?
      yield
    end
  end
end