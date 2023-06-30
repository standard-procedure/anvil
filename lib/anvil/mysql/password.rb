module Anvil
  class Mysql
    module Password
      protected

      def get_password_from option
        if option.nil?
          puts "MySQL password:"
          $stdin.gets.chomp
        else
          option
        end
      end
    end
  end
end
