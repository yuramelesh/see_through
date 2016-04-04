require 'net/smtp'
require 'pp'
require 'active_record'
require 'time'
require 'time_difference'
@config = YAML.load_file('config.yml')

# def send_time_check user
#   utc_time = Time.now.getutc
# end

def get_time_in_coflict pull_request
  start_time = pull_request.added_to_database
  Time.parse(start_time)
  end_time = Time.now
  conflict_time = TimeDifference.between(start_time, end_time).in_hours.to_i
  conflict = "#{conflict_time} hours"
  return conflict
end

def get_mergeable_field pull_request, conflict
  mergeable = pull_request.mergeable
  if mergeable
    merg_status = "<span style='color:green;'><b>No</b></span>"
  else
    merg_status = "<span style='color:red;'><b>Yes</b></span> <b>#{conflict}</b>"
  end
  return merg_status
end

def set_importance pull_request
  case pull_request.mergeable_state
    when 'clean'
      importance = 3
    when 'unstable'
      importance = 2
    when 'dirty'
      importance = 1
    else
      importance = 3
  end
  return importance
end

def get_merg_state importance, conflict
  case importance
    when 3
      merg_state = "<span style='color:green;'><b>Stable</b></span>"
    when 2
      merg_state = "<span style='color:red;'><b>Unstable</b></span> <b>#{conflict}</b>"
    when 1
      merg_state = "<span style='color:red;'><b>Unstable</b></span> <b>#{conflict}</b>"
    else
      merg_state = ''
  end
  return merg_state
end

def get_your_problem_pr your_block
  your_problem_pr = ''
  if your_block.length > 0
    your_problem_pr << "<h2>My pull requests with issues</h2>"
    your_block.each do |i|
      your_problem_pr << i[:text].to_s
    end
    your_problem_pr << "</div>"
  end
  return your_problem_pr
end

def other_problem_pr other_block
  other_problem_pr = ''
  if other_block.length > 0
    other_problem_pr << "<hr><h2>Pull requests with issues</h2>"
    other_block.each do |i|
      if i[:index] < 3
        other_problem_pr << i[:text].to_s
      end
    end
    other_problem_pr << "</div>"
  end
  return other_problem_pr
end

def recently_merged_pr first_hr, repo
  recently_merged = ''
  recently_merged << "#{first_hr}<h2>Recently merged pull requests</h2>"
  PullRequest.all.where(state: 'merged').each do |pull_request|
    recently_merged << "<h3>Pull Request -  #{pull_request.title} <a href='https://github.com/#{repo}/pull/#{pull_request.pr_id}/'>##{pull_request.pr_id}</a></h3>
    <p>Author: #{pull_request.author}</p>"
  end
  recently_merged << "</div>"
  return recently_merged
end

def new_pr other_block
  new_pr = ''
  if other_block.length > 0
    new_pr << '<hr><h2>New pull requests</h2>'
    other_block.each do |i|
      if i[:index] == 3
        new_pr << i[:text].to_s
      end
    end
    new_pr << '</div>'
  end
  return new_pr
end

def mail_send user_to

  repo = @config['repositories'][0]['name']
  pull_requests = PullRequest.all.where(state: 'open')
  other_block = []
  your_block = []

  pull_requests.each do |pull_request|

    conflict = get_time_in_coflict pull_request

    merg_status = get_mergeable_field pull_request, conflict

    importance = set_importance pull_request

    merg_state = get_merg_state importance, conflict

    block = ({index: importance, text: "
        <h3>Pull Request -  #{pull_request.title} <a href='https://github.com/#{repo}/pull/#{pull_request.pr_id}/'>##{pull_request.pr_id}</a></h3>
        <p>Author: #{pull_request.author}</p>
        <p>Build status: #{merg_state}</p>
        <p>Has conflicts: #{merg_status}</p>
        <p>Committers: #{pull_request.committer}</p>
        <br /><br />
    "})

    if pull_request.author == user_to.user_login
      if importance == 2
        your_block.push(block)
      elsif importance == 1
        your_block.push(block)
      else
        other_block.push(block)
      end
    else
      other_block.push(block)
    end

  end

  your_block = your_block.sort_by { |block| block[:index] }
  other_block = other_block.sort_by { |block| block[:index] }

  your_problem_pr = get_your_problem_pr your_block

  first_hr = ''
  if your_block.length > 0
    first_hr = '<hr>'
  end

  other_problem_pr = other_problem_pr other_block
  recently_merged = recently_merged_pr first_hr, repo
  new_pr = new_pr other_block

  message = <<EOF
From: #{repo} <FROM@gmail.com>
To: WorkGroup
Subject: Status Report - #{repo}
Mime-Version: 1.0
Content-Type: text/html

  #{your_problem_pr}

  #{recently_merged}

  #{new_pr}

  #{other_problem_pr}

EOF

  smtp = Net::SMTP.new('smtp.gmail.com', 587)
  smtp.enable_starttls
  smtp.start('SeeThrough', ENV['SEE_THROUGH_EMAIL'], ENV['SEE_THROUGH_EMAIL_PASS'], :login) do |smtp|
    smtp.send_message message, ENV['SEE_THROUGH_EMAIL'], user_to.user_email
  end
end
