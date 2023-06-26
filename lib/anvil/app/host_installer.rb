# frozen_string_literal: true

require "standard_procedure/async"
module Anvil
  class App
    class HostInstaller < Struct.new(:configuration, :host, :secrets)
      include StandardProcedure::Async::Actor

      async :call do
      end
    end
  end
end
