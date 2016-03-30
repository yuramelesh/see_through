require 'net/smtp'
require 'pp'
require 'active_record'
require 'time'
require 'time_difference'
require_relative 'Config'

def mail_send

  pull_requests = PullRequest.all

  message_block = []

  pull_requests.each do |pull_request|

    start_time = pull_request.added_to_database
    Time.parse(start_time)
    end_time = Time.now
    conflict_time = TimeDifference.between(start_time, end_time).in_minutes.to_i

    conflict = ""
    merg_status = ' '
    mergeable = pull_request.mergeable
    if mergeable
      merg_status = "<span style='color:green;'><b>YES</b></span>"
    else
      merg_status = "<span style='color:red;'><b>NO</b></span>"
      conflict = "<p>Time in conflict: #{conflict_time} minutes</p>"
    end


    merg_state = ''
    case pull_request.mergeable_state
      when 'clean'
        merg_state = "<span style='color:green;'><b>build stable</b></span>"
      when 'unstable'
        merg_state = "<span style='color:red;'><b>build unstable</b></span>"
      when 'dirty'
        merg_state = "<span style='color:red;'><b>build unstable</b></span>"
      else
    end

    message_block.push("
        <h3>Pull Request -  #{pull_request.title}<a href='https://github.com/#{REPO}/pull/#{pull_request.pr_id}/'>  ##{pull_request.pr_id}</a></h3>
        <p>Author: #{pull_request.author}</p>
        <p>Build status: #{merg_state}</p>
        <p>Can be merged: #{merg_status}</p>
        #{conflict}
        <p>Committers: #{pull_request.committer}</p>
        <br /><br />
    ")

  end

  message = <<EOF
From: #{REPO} <FROM@gmail.com>
To:
Subject: Status Report - #{REPO}
Mime-Version: 1.0
Content-Type: text/html
EOF

  message_block.each do |i|
    message.concat(i.to_s)
  end

  # smtp = Net::SMTP.new('smtp.gmail.com', 587)
  # smtp.enable_starttls
  # smtp.start('gmail.com', STATIC_USER_EMAIL, STATIC_USER_PASSWORD, :login) do |smtp|
  #   smtp.send_message message, STATIC_USER_EMAIL, USER_MAILS
  # end
end