class Repository

  attr_accessor :repository_name, :recipients

  def initialize (name, recipients)
    @repository_name = name
    @recipients = recipients
  end
end