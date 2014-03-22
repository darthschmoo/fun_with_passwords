require 'helper'

class TestFunWithPasswords < FunWith::Passwords::TestCase  
  should "test basics" do
    assert defined?( FunWith::Passwords )    # utterly useless test
    assert defined?( FunWith::Passwords::Console )
    assert defined?( FunWith::Passwords::Crypt )
  end
  
  should "test fun_with_files integrating properly" do
    assert defined?(FunWith::Files)
    assert defined?(FunWith::Files::FilePath)
    assert [].fwf_blank?
  end
end
