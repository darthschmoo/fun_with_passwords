module FunWith
  module Passwords
    class KeySetError < Exception; end
    
    # Data structure that KeyChain relies on to hold the actual passwords
    class KeySet
      NAMESPACE_CHAR = ":"
      def initialize( hash = {} )
        @keys = {}
        
        for key, val in hash
          @keys[key] = (val.is_a?(Hash)) ? KeySet.new(val) : val
        end
      end
      
      def lookup( key )
         key = namespace_array( key )
         val = @keys[key.first]
         
         if key.length == 1
           if val.is_a?(String)
             return val
            else
              raise KeySetError.new( "Lookup failed 1" )
            end
         else
           if val.is_a?(KeySet)
             return val.lookup( key[1..-1] )
           else
             raise KeySetError.new( "Lookup failed 2")
           end
         end
      end
      
      def modify( key, password )
        key = namespace_array( key )
        
        if key.length == 1
          if @keys[key.first] && @keys[key.first].is_a?(KeySet)
            raise KeySetError.new( "Lookup failed 3" )
          end
          @keys[key.first] = password
        else
          (@keys[key.first] ||= KeySet.new()).modify( key[1..-1], password )
        end
      end
      
      def each( &block )
        for key, val in self.keys_depth_first
          yield key, val
        end
      end
      
      protected
      def namespace_array( key )
        if key.is_a?( String )
          key.split( NAMESPACE_CHAR )
        else
          key
        end
      end
      
      def keys_depth_first( keystack = [] )
        rval = []

        for key, val in @keys
          keystack << key
          if val.is_a?(KeySet) 
            rval += val.keys_depth_first( keystack.clone )
          else
            full_key = keystack.join(NAMESPACE_CHAR)
            rval += [[full_key, val]]
          end
          keystack.pop
        end
        
        rval
      end
    end
  end
end