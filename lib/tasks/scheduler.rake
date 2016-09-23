desc "Update game schedule"
task :update_rosters => :environment do
  puts "Spawning schedule update workers..."
  # TODO:  1.  Only check MLB schedule daily when in-season; every other league should be checked once per season (reschedules are extremely rare) create worker and redis account
  Team.all.each { |t| t.get_schedule }
  puts "Team update workers done spawning."
end