module FunWith
  module Files
    class Password
      attr_accessor :label, :password
      
      def initialize( label, password )
        @label = label
        @password = password
      end
    end
  end
end