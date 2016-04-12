class Profile

  attr_accessor :tz_shift, :login, :id, :email, :enable

  def initialize (login, email, id, tz_shift, enable)
    @login = login
    @email = email
    @id = id
    @tz_shift = tz_shift
    @enable = enable
  end
end