# Sets all passwords to test1234.  To do this on staging, just run:
# cat join_sanitize_staging_passwords.rb | heroku run rails console --app <staging_app>
#
# BE VERY CAREFUL.  If you run this on a real server, you'll wipe all the passwords!
User.all.each do |user|
  user.password = 'test1234'
  user.save!
end

exit

