require 'pg'
require_relative('./DbWorker')
class JobReader < DbWorker
  def do_work(conn, params)
    result_hash = {}

    conn.exec_params('SELECT uid, in_file FROM "PROCESS_QUEUE" pq
                WHERE pq.lock is false
                and out_file is null
                order by submitted_time asc
                limit $1', [params['limit']]) do |result|
      result.each do |row|
        conn.exec_params('UPDATE "PROCESS_QUEUE" SET LOCK = true WHERE UID = $1', [row['uid']]) do
          result_hash[row['uid']] = PG::Connection.unescape_bytea(row['in_file'])
        end
      end
    end
    result_hash
  end
end
