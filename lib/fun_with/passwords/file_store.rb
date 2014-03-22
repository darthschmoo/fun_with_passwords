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
      
      def self.default_file
        DEFAULT_DIR.join( "#{DEFAULT_FILENAME}.#{DEFAULT_EXT}" )
      end

      # if the key is nil, waits until a password is requested or added to decrypt password file
      def initialize( filename = nil )
        @password_file = expand_filepath( filename )
        @password_file.touch
      end
      
      # sends back a Keychain that knows where its store is
      def unlock( master_key )
        if @password_file.file? && !@password_file.empty?
          YAML.load( Crypt.decrypt( @password_file.read, master_key ) )
        else
          {}
        end
      end
      # 
      # def initialize_key_chain_if_needed( keychain_keys, master_key )
      #   unless @key_chain
      #     @key_chain = Keychain.new( :keys => keychain_keys, :master_key => master_key )
      #     @key_chain.file_store = self
      #   end
      # end
      
      def save( yaml, master_key )
        encrypted_message = Crypt.encrypt( yaml, master_key )
        @password_file.write( encrypted_message )
        true
      rescue Exception => e
        false
      end
      
      protected
      # Just the filename?  Send it to the default directory.
      # nil?  Use the default filename and default directory.
      # Only a directory given?  append default filename
      # It's an existing file?  Overwrite, I suppose.
      # doesn't exist?  Assume filename if a dot is included
      def expand_filepath( filename = nil )
        if filename.nil?
          return DEFAULT_DIR.join( "#{DEFAULT_FILENAME}.#{DEFAULT_EXT}" )
        end
        
        file = filename.fwf_filepath
        
        if file.directory?
          return file.join( "#{DEFAULT_FILENAME}.#{DEFAULT_EXT}" )
        elsif file.file?
          return file 
        end
        
        file = file.expand
        
        if file.directory?
          return file.join( "#{DEFAULT_FILENAME}.#{DEFAULT_EXT}" )
        else
          file.touch
          return file
        end
      end
    end
  end
end
