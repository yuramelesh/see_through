require 'net/smtp'
require 'pp'
require_relative 'Config'

def mail_send (send_list)

  message_block = []

  send_list.each do |i|
    login = i.user.to_a[0][1]
    body = i.body
    created_at = i.created_at
    merge_commit_sha = i.merge_commit_sha
    number = i.number
    title = i.title
    state = i.state
    locked = i.locked
    if locked
      alert_color = 'red'
    else
      alert_color = 'green'
    end

    message_block.push("
        <h2>Title: #{title}</h2>
        <p>User: #{login}</p>
        <p>Number: #{number}</p>
        <p>Body: #{body}</p>
        <p>State: #{state}</p>
        <p>Has conflicts: <span style='color: #{alert_color}'>#{locked}</span></p>
        <p>sha: #{merge_commit_sha}</p>
        <p>Created: #{created_at}</p><br /><br />
    ")

  end

  message = <<EOF
From: #{REPO} <FROM@gmail.com>
To: RECEIVER <TO@gmail.com>
Subject: New pull request
Mime-Version: 1.0
Content-Type: text/html
EOF

  message_block.each do |i|
    message.concat(i.to_s)
  end

  smtp = Net::SMTP.new('smtp.gmail.com', 587)
  smtp.enable_starttls
  smtp.start('gmail.com', STATUSER_EMAIL, STATUSER_PASSWORD, :login) do |smtp|
    smtp.send_message message, STATUSER_EMAIL, USER_MAIL
  end
end