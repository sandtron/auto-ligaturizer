require_relative('./DbWorker')
class JobCleaner < DbWorker
  def do_work(conn, _params)
    conn.exec('DELETE from "PROCESS_QUEUE"
        where  submitted_time  < NOW() - interval \'1 days\'')
  end
end
