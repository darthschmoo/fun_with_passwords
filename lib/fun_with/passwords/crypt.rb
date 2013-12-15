module FunWith
  module Passwords
    class Crypt
      IV = "b2f7zaf14kagpd3j76ulddjxytvhjnzvna7diacozrui7afx4d7kj0cxj4ch1of1z7in376vah4kwkarwls0vbtosraovy7d4ci"

      def self.decrypt( encrypted_message, key )
        cipher = OpenSSL::Cipher::AES256.new( :CBC )
        cipher.decrypt
        cipher.key = self.stretch_key(key)
        cipher.iv  = IV
        
        msg = cipher.update( encrypted_message )
        msg << cipher.final
        msg
      end
      
      def self.encrypt( plaintext, key )
        cipher = OpenSSL::Cipher::AES256.new( :CBC )
        cipher.encrypt
        cipher.key = self.stretch_key(key)
        cipher.iv  = IV
        
        encrypted_message = cipher.update( plaintext )
        encrypted_message << cipher.final
        encrypted_message
      end
      
      
      protected
      # Only advantage of doing this is lengthening short, insecure master passwords to
      # randomish-looking key of length needed by the crypto cipher.  Short passwords?
      # Still insecure.  Film at 11.
      def self.stretch_key( key )
        (Digest::MD5.hexdigest(key) + Digest::MD5.hexdigest(key.reverse) ).to_i(16).to_s(36)
      end
    end
  end
end