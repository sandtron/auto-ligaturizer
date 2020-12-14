require 'pg'
require_relative('../sql/DbWorker')
class ReleaseJob < DbWorker
  def uid(uid)
    @uid = uid
    self
  end

  def do_work(conn)
    puts "releasing #{@uid}"
    conn.exec_params('UPDATE "PROCESS_QUEUE" SET LOCK = false WHERE UID = $1', [@uid]) { |res| res.cmd_tuples == 1 }
  end
end
