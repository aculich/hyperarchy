module Hyperarchy
  module Background
    class ComputeElectionScores
      @queue = RACK_ENV

      def self.perform
        puts "computing election scores!!! #{Time.now.to_s}"
        Origin.connection.execute(%{
          update elections set score = ((vote_count + 1) / pow((extract(epoch from (now() - created_at)) / 3600) + 2, 1.8));           
        })
      end
    end
  end
end