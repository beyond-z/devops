# To run on production, connect to production machin and run:
# cd /var/canvas/current && sudo su canvasuser -c "RAILS_ENV=production script/rails console"

connection = LinkedIn::Connection.new

# TODO: substitue the correct user id here
user_id=1234
us = UserService.where(:user_id => user_id, :service => "linked_in").first
puts "### Fetching LinkedIn data for user: #{us.user.name}: #{us.service_user_link}"
request = connection.get_request("/v2/me", us.token)
info = JSON.parse(request.body)
puts "### info = #{info.inspect}"
