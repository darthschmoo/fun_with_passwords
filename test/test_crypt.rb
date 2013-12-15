require 'helper'

class TestCrypt < FunWith::Passwords::TestCase
  should "encrypt and decrypt using Crypt functions" do
    message = "secret message"
    key = "secret key"
    
    encrypted_message = Crypt.encrypt( message, key )
    assert_not_equal( message, encrypted_message )
    decrypted_message = Crypt.decrypt( encrypted_message, key )
    assert_equal( message, decrypted_message )
  end
end