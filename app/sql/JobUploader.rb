require_relative('./DbWorker')
class JobUploader < DbWorker
  def do_work(conn, params)
    conn.exec_params('INSERT INTO "PROCESS_QUEUE"(uid,in_file,submitted_time) values ($1, $2, NOW())',
                     [params['uid'], { value: params['payload'], format: 1 }])
  end
end
