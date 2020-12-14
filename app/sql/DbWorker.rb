class DbWorker
  require 'pg'
  def initialize(host, database, user, port, password)
    @host = host
    @database = database
    @user = user
    @port = port
    @password = password
  end

  def do_work(_conn)
    raise 'Not implemented'
  end

  def execute
    puts "\tconnecting to db"

    conn = PG.connect(dbname: @database, user: @user, port: @port, host: @host, password: @password)
    puts "\tprocessing"
    result = do_work(conn)
    puts "\tprocessed"
    conn.flush
    puts "\tclosing connection"
    conn.finish
    puts "\tclosed"
    result
  rescue Exception => e
    puts e.message
  end
end
