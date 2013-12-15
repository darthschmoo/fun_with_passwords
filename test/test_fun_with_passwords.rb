require 'helper'

class TestFunWithPasswords < FunWith::Passwords::TestCase  
  should "test basics" do
    assert defined?( FunWith::Passwords )
  end
end
