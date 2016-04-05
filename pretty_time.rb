class PrettyTime
  def duration time
    secs  = time.to_int
    mins  = secs / 60
    hours = mins / 60
    days  = hours / 24

    if days > 0
      "#{days} days"
    elsif hours > 0
      "#{hours} hours"
    elsif mins > 0
      "#{mins} minutes"
    elsif secs >= 0
      "just now"
    end
  end
end