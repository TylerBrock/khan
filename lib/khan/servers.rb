module Khan
  class Server
    def initialize(cmd, port, opts=[])
      @cmd = ENV[cmd.upcase] || cmd
      @opts = opts
    end

    def start
      unless running?
        @pid = Process.spawn(@cmd, *@opts, [:in, :out, :err] => :close)
      end
    end

    def stop
      if running?
        kill
        wait
      end
    end

    def running?
      return false unless @pid
      begin
        kill(0) && true
      rescue Errno::ESRCH
        false
      end
    end

    private

    def kill(signal=15)
      Process.kill(signal, @pid)
    end

    def wait
      Process.wait(@pid)
      @pid = nil
    end
  end

  class MongoServer < Server
    def uri
      "http://#{mongod}"
    end

    def host_port
      ['localhost', @port]
    end

    def host_port_string
      host_port.join(':')
    end

    def inspect
      "#<#{@cmd}: @port=#{@port} running=#{running?}>"
    end
  end

  class Mongod < MongoServer
    def initialize
      @port = Networking::get_available_port
      @path = File.join(Dir.getwd, 'khan', "#{cmd}-#{@port}")
      super('mongod', @port, @path)
    end
  end

  class Mongos < MongoServer
  end

  class Replica < Mongod
  end

  class Config < Mongod
  end
end