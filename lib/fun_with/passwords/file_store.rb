module FunWith
  module Passwords

    # The FileStore knows only where to save itself, and how to encrypt
    # and decrypt the file.  The contents of a file are a mystery for
    # Keychain to deal with
    class FileStore
      DEFAULT_DIR = XDG['CONFIG'].fwf_filepath.join("fun_with_passwords")
      DEFAULT_EXT = "aes256.dat"
      DEFAULT_FILENAME = "password_store"
          
      attr_accessor :password_file, :key_chain

      # if the key is nil, waits until a password is requested or added to decrypt password file
      def initialize( password_file = nil )
        if password_file
          @password_file = password_file.fwf_filepath
          if @password_file.directory?
            @password_file = @password_file.join( "#{DEFAULT_FILENAME}.#{DEFAULT_EXT}" )
          end
        else
          @password_file = DEFAULT_DIR.join( "#{DEFAULT_FILENAME}.#{DEFAULT_EXT}" )
        end
      end
      
      # sends back a Keychain that knows where its store is
      def unlock( master_key )
        if @password_file.file? 
          keychain_keys = Crypt.decrypt( @password_file.read, master_key )
        else
          keychain_keys = {}.to_yaml
        end
        
        initialize_key_chain_if_needed( keychain_keys, master_key )
        
        @key_chain
      end

      def initialize_key_chain_if_needed( keychain_keys, master_key )
        unless @key_chain
          @key_chain = Keychain.new( :keys => keychain_keys, :master_key => master_key )
          @key_chain.file_store = self
        end
      end
      
      def save( yaml, master_key )
        encrypted_message = Crypt.encrypt( yaml, master_key )
        @password_file.write( encrypted_message )
        true
#      rescue Exception => e
        false
      end
    end
  end
end
