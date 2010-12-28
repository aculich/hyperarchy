module Hyperarchy
  module Jobs
    class ComputeElectionScores
      @queue = RACK_ENV

      def self.perform
        Origin.connection.execute(%{
          update elections set score = ((vote_count + 1) / pow((extract(epoch from (now() - created_at)) / 3600) + 2, 1.8));           
        })
      end
    end
  end
end