require_relative('../sql/DbWorker')
class LigaturizerResultUploader < DbWorker
  def payload(payload)
    @payload = payload
    self
  end

  def uid(uid)
    @uid = uid
    self
  end

  def do_work(conn)
    conn.exec_params('UPDATE "PROCESS_QUEUE" SET out_file = $1, processed_time = NOW(), lock = false WHERE uid = $2',
                     [{ value: @payload, format: 1 }, @uid]) { |res| res.cmd_tuples == 1 }
  end
end
