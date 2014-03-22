module FunWith
  module Passwords
    class CommandLineResult
      attr_reader :success, :output, :errors, :args
      
      def initialize( args )
        @args = args
        @errors = []
        @output = ""
      end
      
      def stderr( msg )
        STDERR.puts( msg ) if @verbose
        @errors << msg
      end
      
      def stdout( msg )
        STDOUT.write( msg ) if @verbose
        @output << msg
      end
      
      def puts( msg )
        stdout( msg + "\n" )
      end
      
      def puts_error( msg )
        stderr( msg + "\n" )
      end
      
      def fail!
        @success = false
      end
      
      def failed?
        @success == false
      end
      
      def succeed!
        @success = true
      end
      
      def success?
        @success
      end
      
      def verbose( verbosity = nil )
        @verbose = !!verbosity unless verbosity.nil?
        @verbose
      end
      
      def verbose?
        
      end
    end
  end
end