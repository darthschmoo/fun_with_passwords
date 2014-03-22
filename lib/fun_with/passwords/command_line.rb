module FunWith
  module Passwords
    ACTION_KEYWORDS_TO_ACTIONS = {
          "init"       => :initialize,
          "initialize" => :initialize,
          "new"        => :initialize,
          "create"     => :initialize,
          "add"        => :add,
          "insert"     => :add,
          "remove"     => :remove,
          "rm"         => :remove,
          "rmv"        => :remove,
          "drop"       => :remove,
          "delete"     => :delete,
          "del"        => :delete,
          "display"    => :display,
          "disp"       => :display,
          "reveal"     => :display,
          "show"       => :display,
          "view"       => :display,
          "help"       => :help,
          "h"          => :help,
          "rekey"      => :rekey
        }
    
    class CommandLine
      def initialize( args )
        @args = args
        @result = CommandLineResult.new( @args.dup )  # false shuts it up
        
        parse_args()
        
        @console = Console.new
      end
      
      def verbose( verbosity = nil )
        @verbose = verbosity unless verbosity.nil?
        @result.verbose( @verbose )
        !!@verbose
      end
      
      def run
        return @result if @result.failed?
        
        case @action
        when :initialize
          if @file.exist?
            @result.puts "File #{@file} already exists"
            @result.fail!
            return @result
          end
          
          get_master_key()
          @keychain = Keychain.new( :keys => {}, :master_key => @master_key, :file => @file )
          @keychain.save
          @result.puts( "Saved new password file at #{@file}" )
        when :add
          unlock()
          if @keychain[@key].nil? || Console.new.confirm( "Replace current password for key #{@key}?" )
            @keychain[@key] = @pass
            @keychain.save
          end
        when :remove
          unlock()
          pass = @keychain.delete( @key )
          
          if pass.fwf_blank?
            @result.puts "No such key as #{@key}. No action taken."
            return @result
          end
          
          @keychain.save
        when :display
          unlock()
          for key, pass in @keychain
            @result.puts "#{key} : #{pass}"
          end
        when :rekey
          unlock()
          new_key = @new_master_key || Console.ask_for_asterisks( "Enter the NEW master key for #{@file}? " )
          @keychain.save( new_key )
        when :help
          print_help
        end
        
        return @result
      rescue OpenSSL::Cipher::CipherError => e
        @result.stderr( "Cipher error, probably bad master password given. message: #{e.message}")
        @result.fail!
        @result
      end
      
      protected
      
      def parse_args()
        if @args.length == 0
          @action = :help
        else
          @action = ACTION_KEYWORDS_TO_ACTIONS[ (keyword = @args.shift) ]
                    
          
          case @action
          when nil
            @result.puts_error( "Unrecognized keyword #{keyword}" )
            @result.fail!
            print_help
          when :add
            @key, @pass = key_and_pass( @args.shift )
          when :remove
            @key = @args.shift
          when :display
            # do nothing
          else
            # do nothing
          end
          
          while @args.length > 0
            arg = @args.shift
            
            if m = /^--file=(.*)$/.match(arg)
              @file = unquote( m[1] ).fwf_filepath.expand
            elsif m = /--master=(.*)$/.match(arg)
              @master_key = unquote( m[1] )
            elsif m = /--new_master=(.*)$/.match(arg)
              @new_master_key = unquote( m[1] )
            elsif arg == "--quiet"
              @verbose = false
              @result.verbose( false )
            else
              @result.puts_error( "Unrecognized option #{arg}" )
              @result.fail!
            end
          end
          
          @file ||= FileStore.default_file
        end
      end      
      
      
      def unquote( str )
        if str =~ /^(?<q>["']).*(?<q>)$/
          str[1..-2]
        else
          str
        end
      end
      
      def print_help
        @result.puts "\tfwpass new (opts) (create new password file)"
        @result.puts "\tfwpass add <KEY>=<PASS> (opts)    (add a key to an existing password file)"
        @result.puts "\tfwpass rm <KEY> (opts)   (remove a key from a password file)"
        @result.puts "\tfwpass show (opts)   (show contents of password file)"
        @result.puts "\tfwpass rekey (opts)    (swap the master key for a new one.  must know the current key)"
        @result.puts "\tOptions:"
        @result.puts "\t\t--file=<PASSWORD_FILE> (default file: #{FileStore.default_file})"
        @result.puts "\t\t--master=<PASSWORD> ('master key' to unlock the password file)"
        @result.puts "\t\t--new_master=<PASSWORD> (the new 'master key' that will unlock the file hereafter) (option ignored except by rekey command)"
      end
    
      def get_master_key
        @master_key ||= @console.ask_for_master_key(@file)
      end
      
      def unlock
        get_master_key()
        @keychain = Keychain.new( :master_key => @master_key, :file => @file ).unlock
      end
      
      def key_and_pass( str )
        # matches things like "key"='password' key="P4s5w0rd"
        # regexp = /^(?<q1>["']?)(?<key>.*)(?<q1>)=(?<q2>["']?)(?<pass>.*)(?<q2>)$/
        regexp = /^(?<key>(?<q1>["']?).*?(?<q1>))=(?<pass>(?<q2>["']?).*(?<q2>))$/    # wrong: reruns expression
        regexp = /^(?<key>(?<q1>["']?).*?\k<q1>)=(?<pass>(?<q2>["']?).*\k<q2>)$/     # right: looks for the matched text
        match_data = regexp.match( str )

        if match_data
          [unquote(match_data["key"]), unquote(match_data["pass"])]
        else
          [nil, nil]
        end
      end
    end
  end
end