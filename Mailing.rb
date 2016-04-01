require 'net/smtp'
require 'pp'
require 'active_record'
require 'time'
require 'time_difference'
@config = YAML.load_file('config.yml')

def mail_send
  repo = @config['repositories'][0]['name']

  pull_requests = PullRequest.all

  message_block = []

  pull_requests.each do |pull_request|

    start_time = pull_request.added_to_database
    Time.parse(start_time)
    end_time = Time.now
    conflict_time = TimeDifference.between(start_time, end_time).in_hours.to_i
    conflict = "#{conflict_time} hours"

    mergeable = pull_request.mergeable
    if mergeable
      merg_status = "<span style='color:green;'><b>No</b></span>"
    else
      merg_status = "<span style='color:red;'><b>Yes</b></span> <b>#{conflict}</b>"
    end

    merg_state = ''
    importance = 3
    case pull_request.mergeable_state
      when 'clean'
        merg_state = "<span style='color:green;'><b>Stable</b></span>"
      when 'unstable'
        importance = 2
        merg_state = "<span style='color:red;'><b>Unstable</b></span> <b>#{conflict}</b>"
      when 'dirty'
        importance = 1
        merg_state = "<span style='color:red;'><b>Unstable</b></span> <b>#{conflict}</b>"
      else
    end

    message_block.push({index: importance, text: "
        <h3>Pull Request -  #{pull_request.title} <a href='https://github.com/#{repo}/pull/#{pull_request.pr_id}/'>##{pull_request.pr_id}</a></h3>
        <p>Author: #{pull_request.author}</p>
        <p>Build status: #{merg_state}</p>
        <p>Has conflicts: #{merg_status}</p>
        <p>Committers: #{pull_request.committer}</p>
        <br /><br />
    "})

  end

  message_block = message_block.sort_by { |block| block[:index] }

  message = <<EOF
From: #{repo} <FROM@gmail.com>
To: WorkGroup
Subject: Status Report - #{repo}
Mime-Version: 1.0
Content-Type: text/html
EOF

  message_block.each do |i|
    message << i[:text].to_s
  end

  recipients = User.all.where(daily_status: true)
  mails_list = []
  recipients.each do |user|
    mails_list.push(user.user_email)
  end

  smtp = Net::SMTP.new('smtp.gmail.com', 587)
  smtp.enable_starttls
  smtp.start('SeeThrough', ENV['SEE_THROUGH_EMAIL'], ENV['SEE_THROUGH_EMAIL_PASS'], :login) do |smtp|
    smtp.send_message message, ENV['SEE_THROUGH_EMAIL'], mails_list
  end
end