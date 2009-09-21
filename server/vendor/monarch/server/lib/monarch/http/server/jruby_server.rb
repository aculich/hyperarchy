module Http
  class Server
    class << self
      attr_reader :instance

      def start(options)
        @instance = new
        instance.start(options)
      end
    end

    def start(options)
      port = options.delete(:port) || 8080
      Thin::Server.start(port) do
#        use Benchmarker
        use Rack::ContentLength
        use Rack::ShowExceptions
        use AssetService, AssetManager.instance
        use SessioningService
        run Dispatcher.instance
      end
    end
  end
end
