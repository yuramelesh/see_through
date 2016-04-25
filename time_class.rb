require 'time'
require 'time_difference'

class TimeClass

  def duration (time)
    secs = time.to_int
    mins = secs / 60
    hours = mins / 60
    days = hours / 24

    if days == 1
      "#{days} day"
    elsif days > 0
      "#{days} days"
    elsif hours == 1
      "#{hours} hour"
    elsif hours > 0
      "#{hours} hours"
    elsif mins > 0
      "#{mins} minutes"
    elsif secs >= 0
      "just now"
    end
  end

  def get_conflict_time (pull_request)
    start_time = pull_request.added_to_database
    Time.parse(start_time)
    conflict_time = TimeDifference.between(start_time, Time.now).in_seconds.to_i
    duration conflict_time
  end

  def check_time (user_tz)
    local_time = Time.now.getlocal(user_tz)
    if local_time.hour == 9
      return true
    end
    return false
  end

  def check_24_hours_past (sent_at)
    TimeDifference.between(Time.new.utc, sent_at).in_hours.to_i >= 24
  end
end