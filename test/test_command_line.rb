require 'helper'

class TestCommandLine < FunWith::Passwords::TestCase  
  should "test basics" do
    tmpdir do
      file = @tmpdir.join( 'passwords.aes256.dat' )
      file_arg = "--file=#{file}"
      master_arg = "--master=pass1"
      master_arg2 = "--master=pass2"
      new_master_arg = "--new_master=pass2"
      bad_password = "--master=wrong"
      refute file.exist?
      # how to simulate user entering password...
      run_console( ["new", file_arg, master_arg, "--quiet"] )
      assert file.exist?
      
      run_console( ["add", "site1:mysql=pass1", file_arg, master_arg, "--quiet"] )
      run_console( ["add", "site2:mysql=pass2", file_arg, master_arg, "--quiet"] )

      run_console( ["show", file_arg, master_arg, "--quiet"] ) do |result|
        assert_equal "site1:mysql : pass1\nsite2:mysql : pass2", result.output.strip
      end
      
      run_console( ["rekey", file_arg, master_arg, new_master_arg])
      
      run_console( ["rm", "site1:mysql", file_arg, master_arg2, "--quiet"] )
      run_console( ["rm", "site2:mysql", file_arg, master_arg2, "--quiet"] )
      
      run_console( ["rm", "site2:mysql", file_arg, bad_password, "--quiet"] ) do |result|
        assert_match /Cipher error/, result.errors.first
        refute result.success?
      end
      
      
      # puts "\tfwpass new <OPTIONAL_FILENAME>   (create new password file)"
      # puts "\tfwpass add key=password <OPTIONAL_FILENAME>   (add a key to an existing password file)"
      # puts "\tfwpass rm key <OPTIONAL_FILENAME>   (remove a key from a password file)"
      # puts "\tfwpass show <OPTIONAL_FILENAME>   (show contents of password file)"
      # puts "\tfwpass rekey <OPTIONAL_FILENAME>   (swap the master key for a new one.  must know the current key)"
      # puts "\t(default file: #{FileStore.default_file})"
    end
  end
  
  should "properly parse key=value pairs" do
    successes = FunWith::Passwords.root("test", "data", "kvpair_successes.txt").read.split("\n")
    
    cmd = CommandLine.new(["help"])
    
    for line in successes
      str, expected_key, expected_pass = line.split("|")
      
      actual_key, actual_pass = cmd.send( :key_and_pass, str )

      refute actual_key.nil?
      refute actual_pass.nil?
      refute actual_key.fwf_blank?
      refute actual_pass.fwf_blank?
      
      assert_equal( expected_key, actual_key )
      assert_equal( expected_pass, actual_pass )
      
    end
  end
  
  
  
  def run_console( args, &block )
    result = CommandLine.new( args ).run
    
    if block_given?
      yield result
    else
      result
    end
  end
end