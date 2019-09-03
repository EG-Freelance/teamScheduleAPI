class Team < ActiveRecord::Base
  has_many :games
  
  def self.get_schedule(sport)
    teams = Team.where(sport: sport)
    teams.each { |t| puts "getting #{t.full_name} schedule...."; t.get_schedule }
  end
  
  def get_schedule
    Time.zone = "Eastern Time (US & Canada)"
    agent = Mechanize.new
    sport = self.sport
    team = self.espn_abbv
    season = Date.today.year
    
    if self.sport == "nfl"
      # Set preseason variable to change once the preseason section is found
      preseason = ""
      agent.get("http://www.espn.com/nfl/team/schedule/_/name/#{team.downcase}/")
      content = Nokogiri::HTML(agent.page.content)
      games = content.css('tr')

      games_array = games.map { |g| g.css('td').map { |td| td } }
      games_array.delete_if { |ga| ga.count > 20 } # regular listings currently have up to 8 el, concats have 140+
      games_array.each do |g|
        next if g[0].text.downcase == "regular season" || g[0].text.downcase == "wk"
        # add P to preseason if beginning preseason games
        if g[0].text.downcase == "preseason"        
          preseason = "P"
          next
        end
        # week number
        week = (preseason + g[0].text.match(/\A(\d{1,2})/)[1]).rjust(2 ,"0")
        date = g[1].text
        unless g[1].text == "BYE WEEK"
          time = g[3].text.strip
          if g[3].text.downcase.strip == "postponed"
            postponed = true
          else
            postponed = false
          end
        end

        if date.downcase.match(/jun|jul|aug|sep|oct|nov|dec/)
          year = season
        elsif date.downcase.match(/jan|feb|mar|apr|may/)
          year = season + 1
        else
          year = "N/A"
        end
        if year == "N/A" || postponed
          game_date = nil
          opp = "BYE WEEK"
          if postponed
            opp = opp + " (POSTPONED)"
          end
          home = nil
        else
          game_date = Time.zone.parse("#{date} #{year} #{time}").to_datetime
          opp_abbv = g[2].css('a').attr('href').value.match(/\/name\/([A-Za-z]{2,3})\//)
          opp = Team.find_by(sport: "nfl", espn_abbv: opp_abbv[1].upcase).full_name unless opp_abbv.nil?
          if g[2].text.match(/\@/).nil?
            home = true
          else
            home = false
          end
        end
        game = Game.where(week: week, season: season, team_id: self.id).first_or_create
        game.update(date: game_date, home: home, opponent: opp)
      end      
    else # if sport != 'nfl'
      if (sport == 'nba' || sport == 'nhl')
        m = Date.today.month
        if (m == 8 || m == 9 || m == 10 || m == 11 || m == 12)
          season = Date.today.year + 1
        end
      end
      match = 0
      while match == 0 do
        agent.get("http://espn.go.com/#{sport}/teams/printSchedule/_/team/#{team}/season/#{season}")
        content = Nokogiri::HTML(agent.page.content)
        games = content.css('tr td tr')
        if games.count > 5
          match = 1
        else
          season = season - 1
        end
      end
      (sport == 'nba' || sport == 'nhl') ? team_season = "#{season-1}-#{season.to_s[2..3]}" : team_season = season.to_s
      games_array = games.map{ |g| g.text }
      games_array.delete_if{ |g| g[0..4] == " Date" }
      games_array.each do |g|
        if (sport == "nhl") || (sport == "nba")
          if g[0..2].match(/Aug|Sep|Oct|Nov|Dec/)
            year = season - 1
          elsif g[0..2].match(/Jan|Feb|Mar|Apr|May|Jun|Jul/)
            year = season
          else
            puts "Error parsing year in #{g}"
            return false
          end
        end
        date = Time.zone.parse((g.match(/([a-z]{3,4}\.?\s\d{1,2})/i)[1] + " #{year} " + g.match(/(\d{1,2}:\d{2}\z)/)[1] + " pm").gsub(".", "")).to_datetime
        opp = g.match(/[\dat\s]?([A-Z]+[A-Za-z\s\.]+\.?\s?[a-z]*)\n/)[1]
        if sport == 'nba'
          if opp == "LA"
            opp = "LA Clippers"
          elsif opp == "Los Angeles"
            opp = "LA Lakers"
          end
        end
        if g.match(/\dat\s/).nil?
          home = true
        else
          home = false
        end
        Game.where(week: "N/A", date: date, season: team_season, home: home, opponent: opp, team_id: self.id).first_or_create
      end
    end
  end
end
