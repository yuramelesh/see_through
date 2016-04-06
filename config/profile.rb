class Profile

  attr_accessor :tz_shift, :login, :email, :enable

  def initialize login, email, tz_shift, enable
    @login = login
    @email = email
    @tz_shift = tz_shift
    @enable = enable
  end
end