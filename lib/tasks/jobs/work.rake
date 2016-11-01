namespace :jobs do
  desc "Email delivery loop"
  task work: :environment do
    while true
      begin
        DeliverMailJob.perform_now
      rescue Exception => e
        Rails.logger.error(e)
      end
      sleep 30
    end
  end
end
