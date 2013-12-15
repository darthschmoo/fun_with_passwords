module FunWith
  module Passwords
    class Console
      def self.ask_for_password( key = nil )
        key ||= ask( "Lookup string for this password?: ")
        pass = ask_for_asterisks( "Enter the password for key #{key}: " )
        [key, pass]
      end
      
      def self.ask_for_master_key( file )
        ask_for_asterisks( "Enter the master key for #{file}: ")
      end
      
      protected
      def self.ask_for_asterisks( msg )
        ask( msg ){ |q| q.echo = "*" }
      end
    end
  end
end