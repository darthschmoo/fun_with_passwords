module FunWith
  module Passwords
    class Keychain
      NAMESPACE_CHAR = ":"
      
      attr_accessor :file_store
      
      def initialize( opts = {} ) 
        file = opts[:file]
        keys = opts[:keys] || {}
        @file_store = FileStore.new( file ) if file
        @master_key = opts[:master_key] || Console.ask_for_master_key
        set_keys( keys )
      end
      
      # if no new master key is given, save with the old one.
      def save( master_key = nil)
        @master_key = master_key if master_key
        if @file_store
          @file_store.save( @keys.to_yaml, @master_key )
        end
      end
      
      def unlock( master_key = nil )
        @master_key = master_key if master_key
        
        if @file_store
          set_keys( @file_store.unlock( @master_key ) )
        end
      end
      
      def set_keys( hash = nil )
        if hash
          @keys = hash
        end
      end
      
      def []=( key, password )
        keystack = key.split(NAMESPACE_CHAR)

        hash = @keys
        
        while true
          key = keystack.shift
          val = hash[key]
          if val.nil?
            if keystack.length == 0
              hash[key] = password
              return password
            else
              hash[key] = {}
              hash = hash[key]
            end
          elsif val.is_a?(Hash)
            if keystack.length == 0
              warn( "trying to overwrite existing hash with a password" )
              hash[key] = password
              return password
            else
              hash = val
            end
          elsif val.is_a?(String)
            if keystack.length == 0  # perfect
              hash[key] = password
              return password
            else
              warn( "overwriting existing password with a hash" )
              hash[key] = {}
              hash = hash[key]
            end
          end
        end
      end

      def []( key, ask_on_fail = true )
        puts "HUNTING FOR KEY:  #{key}  in #{@keys}"
        keystack = key.split(NAMESPACE_CHAR)
        
        hash = @keys.clone
        password = nil
        
        while password.nil?
          key = keystack.shift
          val = hash[key]
          
          puts "pass: #{password.inspect} ; key: #{key.inspect} ; val: #{val.inspect}"
          break if val.nil?
          
          if keystack.length == 0
            password = val
          else
            hash = hash[key]
          end
        end
        
        if !password && ask_on_fail
          password = Console.ask_for_password( key )
          self[key] = password  
        end
        
        password
      end
      
      def each( &block )
        rval = self.keys_depth_first( @keys, [] )
        
        if block_given?
          rval.each do |item|
            yield item
          end
        else
          rval.each
        end
      end
      
      def printout
        self.each do |key, password|
          puts "#{key}: #{password}"
        end
      end
      
      protected
      def keys_depth_first( hash, stack )
        rval = []
        
        for key, val in hash
          if val.is_a?(String)
            key_as_string = (stack + [key]).join(NAMESPACE_CHAR)
            rval << [key_as_string, val]
          else
            rval += keys_depth_first( val, stack + [key] )
          end
        end
        
        rval
      end
    end
  end
end
