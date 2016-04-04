require_relative 'database'
require_relative 'octokit_client'

def add_new_pull_request pr_data
  PullRequest.create(
      :title => pr_data[:title],
      :pr_id => pr_data[:number],
      :author => pr_data[:user_login],
      :merged => pr_data[:merged],
      :mergeable => pr_data[:mergeable],
      :mergeable_state => pr_data[:mergeable_state],
      :state => pr_data[:state],
      :pr_commentors => pr_data[:commentors].to_a.join(", "),
      :committer => pr_data[:committer].to_a.join(", "),
      :labels => pr_data[:label].to_a.join(", "),
      :created_at => pr_data[:created_at],
      :updated_at => pr_data[:updated_at],
      :added_to_database => Time.new,
  )

  commentors_list = pr_data[:commentors].to_a
  build_list_of_commentors commentors_list
end

def checking_pr_for_changes pr_data
  existing_pull_requests = PullRequest.all
  existing_pull_requests.each do |pull_request|
    if pr_data[:number] == pull_request.pr_id
      if pull_request.merged != pr_data[:merged]
        pull_request.update(merged: pr_data[:merged])
      end
      if pull_request.state != pr_data[:state]
        pull_request.update(state: pr_data[:state])
      end
      if pull_request.mergeable != pr_data[:mergeable]
        pull_request.update(mergeable: pr_data[:mergeable])
      end
      if pull_request.mergeable_state != pr_data[:mergeable_state]
        pull_request.update(mergeable_state: pr_data[:mergeable_state])
      end
      if pull_request.committer != pr_data[:committer]
        pull_request.update(committer: pr_data[:committer])
      end
      if pull_request.labes != pr_data[:label]
        pull_request.update(labels: pr_data[:label])
      end
    end
  end
end

def check_pr_for_existing pr_data
  if pr_data.length != 0
    if PullRequest.find_by(pr_id: pr_data[:number])
      checking_pr_for_changes pr_data
    else
      add_new_pull_request pr_data
    end
  end
end

def add_new_user login
  user = get_user_by_login login
  User.create(
      :user_login => user.login,
      :user_email => user.email,
      :git_hub_id => user.id,
      :enable => false,
  )
end

def sync_user_with_config user
  daily_report = user.enable
  user_to_update = User.where(user_login: user.login).take
  user_to_update.update(enable: daily_report)
  user_to_update.update(notify_at: user.tz_shift)
  user_to_update.update(user_email: user.email)
end

def get_open_pull_requests
  PullRequest.all.where(state: 'open')
end
