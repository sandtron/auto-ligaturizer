require 'pg'
require_relative('./DbWorker')
class LockReleaser < DbWorker
  def do_work(conn, params)
    puts "releasing #{params['uid']}"
    conn.exec_params('UPDATE "PROCESS_QUEUE" SET LOCK = false WHERE UID = $1',
                     [params['uid']])
  end
end
