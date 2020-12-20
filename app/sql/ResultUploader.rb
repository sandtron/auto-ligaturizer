require_relative('./DbWorker')
class ResultUploader < DbWorker
  def do_work(conn, params)
    conn.exec_params('UPDATE "PROCESS_QUEUE" SET out_file = $1, processed_time = NOW(), lock = false WHERE uid = $2',
                     [{ value: params['payload'], format: 1 }, params['uid']])
  end
end
