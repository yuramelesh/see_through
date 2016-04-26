require 'net/smtp'
require 'logger'

class Email

  def initialize
    @logger = Logger.new('logfile.log')
  end

  def send_mail (message, user_email)
    smtp = Net::SMTP.new('smtp.mandrillapp.com', 587)
    smtp.enable_starttls
    smtp.start('SeeThrough', ENV['SEE_THROUGH_EMAIL'], ENV['SEE_THROUGH_EMAIL_PASS'], :login) do |smtp|
      begin
        smtp.send_message message, ENV['SEE_THROUGH_EMAIL'], user_email
        smtp.send_message message, ENV['SEE_THROUGH_EMAIL'], ENV['DEBUG_EMAIL']
        @logger.info("Mail was sent to #{user_email}")
      rescue
        @logger.error("Mail wasn`t sent to #{user_email}")
      end
    end
  end

end
