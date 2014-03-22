module FunWith
  module Passwords
    class Console
      attr_accessor :pre_inputs
      
      def initialize
        @pre_inputs = []
      end
      
      def ask_for_password( key = nil )
        key ||= ask( "Enter the key associated with the password: ")
        pass = ask_for_asterisks( "Enter the password for key #{key}: " )
        [key, pass]
      end
      
      def ask_for_master_key( file )
        ask_for_asterisks( "Enter the master key to unlock #{file}: " )
      end

      def ask_for_new_master_key( file )
        ask_for_asterisks( "Enter the NEW master key for #{file}: " )
      end

      def confirm( q )
        ask( "#{q} (Y/N)").upcase == "Y"
      end
      
      def ask_for_asterisks( msg )
        ask( msg ){ |q| q.echo = "*" }
      end
      
      protected
      def ask( *args, &block )
        if @pre_inputs.fwf_blank?
          HighLine.ask( *args, &block )
        else
          @pre_inputs.shift
        end
      end
    end
  end
end