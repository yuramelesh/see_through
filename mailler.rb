class Email

  def send_mail (message, user_email)
    smtp = Net::SMTP.new('smtp.mandrillapp.com', 587)
    smtp.enable_starttls
    smtp.start('SeeThrough', ENV['SEE_THROUGH_EMAIL'], ENV['SEE_THROUGH_EMAIL_PASS'], :login) do |smtp|
      smtp.send_message message, ENV['SEE_THROUGH_EMAIL'], user_email
    end
  end

end
