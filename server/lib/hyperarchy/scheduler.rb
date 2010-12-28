module Hyperarchy
  module Scheduler
    extend self

    def start
      Thread.new do
        Thread.abort_on_exception = true
        Clockwork.handler { |task| Resque.enqueue(task) }
        Clockwork.every(1.minute, Jobs::ComputeElectionScores)
        Clockwork.run
      end
    end
  end
end

# makes logging of events work properly for jobs that are classes instead of strings
class Clockwork::Event
  def to_s
    @job.to_s
  end
end