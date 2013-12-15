require 'helper'

class TestKeychain < FunWith::Passwords::TestCase
  KEYHASH = { "hey" => { 
                "sailor" => "password" 
              }, 
              "orangutan" => "marigold",
              "hitch" => {
                "hiker" => {
                  "steve" => "hoboname"
                }
              }
            }
  
  def setup
    @keychain = Keychain.new( :keys => KEYHASH, :master_key => "master_key" )
  end
         
  should "get the correct keys" do
    assert_equal( "password", @keychain["hey:sailor"] )
    assert_equal( "marigold", @keychain["orangutan"] )
  end
  
  should "update a key" do
    @keychain["orangutan"] = "password_orangutan"
    @keychain["hey:sailor"] = "password_sailor"
    
    assert_equal( "password_orangutan", @keychain["orangutan"] )
    assert_equal( "password_sailor", @keychain["hey:sailor"] )
    assert_equal( @keychain["hitch:hiker:steve"], "hoboname")
  end
  
  should "test each(){}" do
    expected = [["hey:sailor", "password"], ["orangutan", "marigold"], ["hitch:hiker:steve", "hoboname"]]

    i = 0
    @keychain.each do |item|
      assert_equal( expected[i], item )
      i += 1
    end
  end
  
  should "write passwords to a file and read them back" do
    tmpdir do
      assert @keychain.file_store.nil?
      @keychain.file_store = FileStore.new(@tmpdir)
      pwfile = @tmpdir.join("password_store.aes256.dat")
      assert_equal( pwfile, @keychain.file_store.password_file )
      assert !@keychain.file_store.password_file.exist?
      
      @keychain.save
      assert @keychain.file_store.password_file.exist?

      @keychain = Keychain.new( :file => pwfile, :master_key => "master_key" )
      @keychain.unlock
      
      assert_equal( "password", @keychain["hey:sailor"] )
      assert_equal( "marigold", @keychain["orangutan"] )
    end
  end
end
