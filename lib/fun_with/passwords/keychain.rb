module FunWith
  module Passwords
    class Keychain
      NAMESPACE_CHAR = ":"
      
      attr_accessor :file_store
      
      # Load an existing
      def self.load( master_key, opts = {} )
        file = opts[:file] || FileStore.default_file
        master_key = Console.new.ask_for_master_key if master_key == :new
        self.new( :file => file, :master_key => master_key ).unlock
      end
      
      def initialize( opts = {} )
        @options = opts
        set_keys
        set_master_key
        set_file_store
      end
      
      # if no new master key is given, save with the old one.
      def save( master_key = nil)
        @master_key = master_key if master_key
        if @file_store
          @file_store.save( @keys.to_yaml, @master_key )
        else
          false
        end
      end
      
      def unlock( master_key = nil )
        @master_key = master_key if master_key
        
        if @file_store
          set_keys( @file_store.unlock( @master_key ) )
        end
        
        self
      end
      
      def set_options
        if @opts[:interactive]
          @ask_on_fail = true
        end
      end
      
      # After @keys is set, subsequent set_keys(nil) calls have no effect.
      def set_keys( hash = nil )
        if hash
          @keys = hash
        else
          @keys ||= @options[:keys] || {}
          @options.delete(:keys)
        end
      end
      
      def set_master_key( key = nil )
        if key
          @master_key = key
        else
          @master_key ||= @options.delete(:master_key)
          @master_key ||= Console.new.ask_for_master_key if @ask_on_fail
        end
      end

      def set_file_store
        @file_store = FileStore.new( @options[:file] ) if @options[:file]
      end
      
      def []=( key, password )
        @keys[key] = password
      end

      def []( key )
        password = @keys[key]
                
        if !password && @ask_on_fail
          password = Console.new.ask_for_password( key )
          self[key] = password  
        end
        
        password
      end
      
      def each( &block )
        if block_given?
          @keys.each(&block)
        else
          @keys.each
        end
      end
      
      def delete( key )
        @keys.delete( key )
      end
      
      def printout
        self.each do |key, password|
          puts "#{key}: #{password}"
        end
      end
    end
  end
end
