require_relative('../sql/DbWorker')
class LigaturizeJobReader < DbWorker
  def do_work(conn)
    result_hash = {}
    conn.exec('SELECT uid, in_file FROM "PROCESS_QUEUE" pq
                WHERE pq.lock is false
                and out_file is null
                order by submitted_time asc
                limit 1') do |result|
      result.each do |row|
        conn.exec_params('UPDATE "PROCESS_QUEUE" SET LOCK = true WHERE UID = $1', [row['uid']]) do
          result_hash['uid'] = row['in_file']
        end
      end
    end
    result_hash
  end
end
