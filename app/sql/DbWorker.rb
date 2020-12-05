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
    conn = PG.connect(dbname: @database, user: @user, port: @port, host: @host, password: @password)
    do_work(conn)
  end
end
