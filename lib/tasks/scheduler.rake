desc "Update game schedule"
task :get_all_scheds => :environment do
  puts "Spawning schedule update workers..."
  # TODO:  1.  Only check MLB schedule daily when in-season; every other league should be checked once per season (reschedules are extremely rare) create worker and redis account
  Team.all.each { |t| t.get_schedule }
  puts "Team update workers done spawning."
end

desc "Update game schedule"
task :update_by_sport => :environment do
  # only check on first day of the month
  if Date.today.strftime("%d").to_i == 1
    month = Date.today.strftime("%m").to_i
    
    # NHL & NBA (only check monthly between September and May)
    if month >= 9 || month <= 5
      Team.get_schedule("nhl")
      Team.get_schedule("nba")
    end
    
    # MLB (only check monthly between February and October)
    if month >= 2 && month <= 10
      Team.get_schedule("mlb")
    end
    
    # NFL (only check monthly between August and January)
    if month >= 8 || month == 1
      Team.get_schedule("nfl")
    end
  end
end