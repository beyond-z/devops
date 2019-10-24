# this creates the magic field for linked in from the auth step if present
# good for fixing up the broken fields...
def amazing
User.all.each do |u|
  u.user_services.each do |service|
   if service.service == "linked_in"
     existing = RetainedData.where(:user_id => u.id, :name => 'user-linkedin-profile').first
     if existing.nil?
      d = RetainedData.new
     else
      d = existing
     end

     if existing.value.blank?
      d.name = 'user-linkedin-profile'
      d.value = service.service_user_link
      d.user_id = u.id
      d.save
      puts "try #{u.id}"
     end
     break
   end
  end
end

nil
end
