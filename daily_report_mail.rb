require 'net/smtp'
require_relative 'config/config_reader'
require_relative 'main_controller'
require_relative 'time_class'
require_relative 'mailler'

# def send_time_check user
#   utc_time = Time.now.getutc
#   utc_time.strftime( "%H" )
# end

@email = Email.new
@main_controller = MainController.new
@time = TimeClass.new

def get_mergeable_field pull_request, conflict
  mergeable = pull_request.mergeable
  if mergeable
    merge_status = "<span style='color:green;'><b>No</b></span>"
  else
    merge_status = "<span style='color:red;'><b>Yes</b></span> <b>#{conflict}</b>"
  end
  merge_status
end

def get_importance pull_request
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
  importance
end

def get_mergeable_state importance, conflict
  case importance
    when 3
      merge_state = "<span style='color:green;'><b>Stable</b></span>"
    when 2
      merge_state = "<span style='color:red;'><b>Unstable</b></span> <b>#{conflict}</b>"
    when 1
      merge_state = "<span style='color:red;'><b>Unstable</b></span> <b>#{conflict}</b>"
    else
      merge_state = ''
  end

  merge_state
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

  your_problem_pr
end

def get_other_problem_pr other_block
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

  other_problem_pr
end

def get_recently_merged_pr first_hr, repo
  recently_merged = ''
  recently_merged << "#{first_hr}<h2>Recently merged pull requests</h2>"
  @main_controller.get_repo_pr_by_state(repo, 'merged').each do |pull_request|
    recently_merged << "<h3>Pull Request -  #{pull_request.title} <a href='https://github.com/#{repo}/pull/#{pull_request.pr_id}/'>##{pull_request.pr_id}</a></h3>
    <p>Author: #{pull_request.author}</p>"
  end
  recently_merged << "</div>"

  recently_merged
end

def get_new_pr other_block
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
  new_pr
end

def create_mail_message user_to, repo

  pull_requests = @main_controller.get_repo_pr_by_state repo, 'open'
  other_block = []
  your_block = []

  pull_requests.each do |pull_request|
    conflict = @time.get_conflict_time pull_request
    merge_status = get_mergeable_field pull_request, conflict
    importance = get_importance pull_request
    merge_state = get_mergeable_state importance, conflict

    block = ({index: importance, text: "
        <h3>Pull Request -  #{pull_request.title} <a href='https://github.com/#{repo}/pull/#{pull_request.pr_id}/'>##{pull_request.pr_id}</a></h3>
        <p>Author: #{pull_request.author}</p>
        <p>Build status: #{merge_state}</p>
        <p>Has conflicts: #{merge_status}</p>
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

  other_problem_pr = get_other_problem_pr other_block
  recently_merged = get_recently_merged_pr first_hr, repo
  new_pr = get_new_pr other_block

  message = <<EOF
From: #{repo} <FROM@vgs.io>
To: WorkGroup
Subject: Status Report - #{repo}
Mime-Version: 1.0
Content-Type: text/html

  #{your_problem_pr}
  #{recently_merged}
  #{new_pr}
  #{other_problem_pr}

EOF
  message
end

def send_mail user_to, repo
  message = create_mail_message user_to, repo
  @email.send_mail(message, user_to.user_email)
end
