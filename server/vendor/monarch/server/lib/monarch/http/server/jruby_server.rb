import "org.mortbay.jetty.handler.AbstractHandler"

module Http
  class Handler < AbstractHandler
    attr_reader :app
    def initialize(&rack_definition)
      @app = Rack::Builder.app(&rack_definition)
    end

    def handle(target, servlet_request, servlet_response, dispatch)
      rack_env = rack_env_from_servlet_request(servlet_request)
      p rack_env
#      rack_response = app.call(rack_env)
      rack_response = [200, {}, "hi"]
      update_servlet_response_with_rack_response(servlet_response, rack_response)
      servlet_request.set_handled(true)
    end

    def rack_env_from_servlet_request(request)
      env = {}
      env['REQUEST_METHOD'] = request.get_method
      env['SCRIPT_NAME'] = ""
      env['PATH_INFO'] = request.get_path_info
      env['QUERY_STRING'] = request.get_query_string

      env
    end

    def update_servlet_response_with_rack_response(servlet_response, rack_response)
      servlet_response.set_status(200)
      servlet_response.get_writer().println("<h1>Hello</h1>")
    end
  end

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
      jetty = org.mortbay.jetty.Server.new(port)
      jetty.set_handler(Handler.new do
        use Rack::ContentLength
        use Rack::ShowExceptions
        use AssetService, AssetManager.instance
        use SessioningService
        run Dispatcher.instance
      end)
      jetty.start
    end
  end
end

