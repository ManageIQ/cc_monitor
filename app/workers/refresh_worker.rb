class RefreshWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  sidekiq_options :retry => false, :queue => :cc_monitor

  recurrence { minutely }

  def perform
    Server.refresh
  end
end
