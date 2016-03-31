require 'net/smtp'
require 'pp'
require 'active_record'
require 'time'
require 'time_difference'

def mail_send

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
    importantly_index = 3
    case pull_request.mergeable_state
      when 'clean'
        merg_state = "<span style='color:green;'><b>Stable</b></span>"
      when 'unstable'
        importantly_index = 2
        merg_state = "<span style='color:red;'><b>Unstable</b></span> <b>#{conflict}</b>"
      when 'dirty'
        importantly_index = 1
        merg_state = "<span style='color:red;'><b>Unstable</b></span> <b>#{conflict}</b>"
      else
    end

    message_block.push({ index: importantly_index, text: "
        <h3>Pull Request -  #{pull_request.title} <a href='https://github.com/#{@config['repo']}/pull/#{pull_request.pr_id}/'>##{pull_request.pr_id}</a></h3>
        <p>Author: #{pull_request.author}</p>
        <p>Build status: #{merg_state}</p>
        <p>Has conflicts: #{merg_status}</p>
        <p>Committers: #{pull_request.committer}</p>
        <br /><br />
    "})

  end

  message_block = message_block.sort_by { |block| block[:index] }

  message = <<EOF
From: #{@config['repo']} <FROM@gmail.com>
To: WorkGroup
Subject: Status Report - #{@config['repo']}
Mime-Version: 1.0
Content-Type: text/html
EOF

  message_block.each do |i|
    message << i[:text].to_s
  end

    smtp = Net::SMTP.new('smtp.gmail.com', 587)
    smtp.enable_starttls
    smtp.start('SeeThrough', @config['mailer'], @config['mailer_pass'], :login) do |smtp|
      smtp.send_message message, @config['mailer'], 'yuramelwsh@gmail.com' #@config['recepients']
    end
end