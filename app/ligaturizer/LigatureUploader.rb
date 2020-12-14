require_relative('../sql/DbWorker')
class LigatureUploader < DbWorker
  def payload(payload)
    @payload = payload
    self
  end

  def uid(uid)
    @uid = uid
    self
  end

  def do_work(conn)
    conn.exec_params('INSERT INTO "PROCESS_QUEUE"(uid,in_file,submitted_time) values ($1, $2, NOW())',
                     [@uid, { value: @payload, format: 1 }]) { |res| res.cmd_tuples == 1 }
  end
end
