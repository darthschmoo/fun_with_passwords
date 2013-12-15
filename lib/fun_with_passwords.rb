require 'fun_with_files'
require 'fun_with_configurations'
require 'fun_with_version_strings'
require 'highline/import'
require 'xdg'
require 'openssl'
require 'yaml'
require 'readline'

module FunWith
  module Passwords
  end
end

FunWith::Files::RootPath.rootify( FunWith::Passwords, __FILE__.fwf_filepath.dirname.up )
FunWith::VersionStrings.versionize( FunWith::Passwords, FunWith::Passwords.root("VERSION").read )

FunWith::Passwords.root( "lib","fun_with" ).requir


