module Hyperarchy
  module Jobs
    class ComputeElectionScores
      @queue = RACK_ENV

      def self.perform
        puts "ComputeElectionScores!!!!!!!!!!!!!!!!!!!!!"
      end
    end
  end
end