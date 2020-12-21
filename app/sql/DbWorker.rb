class DbWorker
  require 'pg'
  def initialize(cfg)
    @host = cfg['host']
    @database = cfg['database']
    @user = cfg['user']
    @port = cfg['port']
    @password = cfg['password']
  end

  def do_work(_conn)
    raise 'Not implemented'
  end

  def execute(params = {})
    # puts "\tconnecting to db"

    conn = PG.connect(dbname: @database, user: @user, port: @port, host: @host, password: @password)
    # puts "\tprocessing"

    result = do_work(conn, params)
    # puts "\tprocessed"
    conn.flush
    # puts "\tclosing connection"
    conn.finish
    # puts "\tclosed"
    result
  rescue StandardError => e
    puts e.message
  end
end
