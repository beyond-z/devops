# To run on production, connect to production machin and run:
# cd /var/canvas/current
# sudo su canvasuser -c "RAILS_ENV=production script/rails console"

connection = LinkedIn::Connection.new

# TODO: substitue the correct user id here
u = User.find(1234)
u.user_services.each do |service|
  if service.service == "linked_in"
    puts "### Fetching LinkedIn data for user: #{u.name}: #{service.service_user_link}"
    request = connection.get_request("/v1/people/~:(id,first-name,last-name,maiden-name,email-address,location,industry,num-connections,num-connections-capped,summary,specialties,public-profile-url,last-modified-timestamp,associations,interests,publications,patents,languages,skills,certifications,educations,courses,volunteer,three-current-positions,three-past-positions,num-recommenders,recommendations-received,following,job-bookmarks,honors-awards)?format=json", service.token)
    info = JSON.parse(request.body)
    puts "### info = #{info.inspect}"
  end
end
