# Turn on debug logging
#Rails.logger.level = 0
#print Rails.logger.level

#regions = List.find_by_friendly_name('bz_regions')
#print regions.inspect

# This prints out a user info
#u = User.find_by_email('<insertEmail')
#print u

# This prints out use info by id
#u = User.find(4851)
#print u

#e = Enrollment.find_by(:user_id => 3688)
#puts e.inspect

# Set the updated date back in time so we can see the welcome page as though
# they are coming back later.
#e = Enrollment.find(1627)
#e.updated_at = Date.today - 2.days
#e.save(validate: false)

#e = Enrollment.find(1585)
#print e.campaign_id

#Save and set their password, e.g. if we want to set it to a known one temporarily to login as them and then set it back
#u = User.find(4378)
#u = User.find_by_email("")
#Do this for a test user with a known password and them to save their password.
#print u.encrypted_password
# Then, set their password to the known one.
#u.encrypted_password = "<insert password to set>"
#u.save
#When done, run the above and set it back to their original.

# Save someones infor into a campaign 
#u = User.find(614)
#          if u.applicant_type == 'undergrad_student' && u.university_name == 'San Jose State University'
#            sf = BeyondZ::Salesforce.new
#            client = sf.get_client
#            client.materialize('CampaignMember')
#
#            cm = SFDC_Models::CampaignMember.new
#            # Staging SJSU participatns
#            cm.CampaignId = '7011700000056Pf'
#            cm.ContactId = u.salesforce_id
#            cm.Apply_Button_Enabled__c = false
#            cm.Application_Decision_Sent__c = false
#            cm.save
#          end

# associate an application to a salesforce campaign
#e = Enrollment.find(id_from_the_url)
#e.campaign_id = '<insertfrom_salesforce>'
#e.save(validate: false)

# unset the program confirmation which controls the welcome screen they see
#u = User.find(3094)
#print u
#u.program_attendance_confirmed = true
#u.save

# Reset the Canvas user id to sync to lms will create a new user
#u = User.find(2433)
#u.canvas_user_id = nil
#u.save

# Set the user's Canvas id so they can login
#u = User.find(4378)
#u.canvas_user_id = 1470
#u.save

# change the applicant type, e.g. if someone signed up as "professional"
#u = User.find(4535)
#u.applicant_type = 'leadership_coach'
#u.applicant_type = 'event_volunteer'
#u.applicant_type = 'undergrad_student'
#u.save

# change a user's email address
#u = User.find_by_email("<insertemail>")
#u.email = "<insertnewemail>"
#u.skip_confirmation!
# tell devise not to send a confirmation email
#u.skip_reconfirmation!
#u.save(validate: false)


#Delete test Brian users
#User.where("email like ? OR email like ?", "%insert_filter%", "%insert_other_filter%").each do |u|
#  print "Deleting: " + u.email + "\n"
#  u.destroy!
#end; nil 

# Delete a user by ID
#u= User.find(2476)
#u.destroy!

#This deletes the enrollment letting them refresh it.
#e = Enrollment.find(1627)
#e.destroy!

# This adds the unconfirmed bz.org users to salesforce so that if they activate their email, it will work
#User.where(:confirmed_at => nil, :salesforce_id => nil).each do |u|
  #if u.created_at > Date.new(2015,3,30 ) then # the users before this were from old recruitment efforts
#  u.create_on_salesforce
  #print u.email + "\t" + u.created_at.to_s + "\n"
  #end
#end; nil


# This updates the application for someone to be owned by him, not admin.
#e = Enrollment.find(315)
#e.user_id = 563
#e.save(validate: false)
#Enrollment.find_by(:user_id => 563).id

# This checks if this user is confirmed or not
#u = User.find_by_email("<insertemail>")
#u.confirmed?

#Enrollment.find(305).campaign_id

# This creates a new user by email:
#u = User.new(:email => '<insertemail>', :bz_region => 'San Francisco Bay Area, San Jose')
#u.skip_confirmation!
#u.save
#print u

# Print out all enrollments for a user
#enrollments = Enrollment.where(:user_id => 4422).each do |e|
#  print e.id
#  print "\n"
#  print e.campaign_id
#  print "\n"
#  print e.inspect
#end;

# Clears out the resume library
#Resume.destroy_all

#Clears out the Salesforce cache of emails
#SalesforceCache.all.each do |item|
#  item.destroy!
#end

# Clears out the Rails cache for things like SF campaigns
#Rails.cache.clear

# Print BZ User Id to Canvas ID mappings.
#puts "bz user id, canvas id"
#User.all.each do |u|
#  if u.canvas_user_id
#    puts "#{u.id},#{u.canvas_user_id}"
#  end
#end; nil

# Create script to update Braven Help database with new Open ID URls
#User.all.each do |u|
#  if u.canvas_user_id
#    puts "update forum_authkeyuserassociation set key = 'https://portal.bebraven.org/openid/user/#{u.canvas_user_id}' where  key like '%openid/user/#{u.id}';"
#  end
#end; nil

#
#champions = Champion.where('id IN (?)', champion_ids)
#champions.all.each do |champ|
#  puts ""
#  print champ.inspect
#end

# Find a Braven Champion by champion ID
#c = Champion.find(1)
#print c

# Print champions who don't want to be contacted
#champions = Champion.where(:willing_to_be_contacted => false)
#print champions.inspect

# Find a Braven Champion by email address:
#champions = Champion.where(:email => '<insertemail>')
#champions = Champion.where('email = ? OR email = ? OR email = ?', '<insertemail1>', '<insertemail2>', '<insertemail3>').all
#champions = Champion.where('email LIKE ?', '%@bebraven.org').all
#champions = Champion.where('linkedin_url LIKE ?', '').all # get empty LinkedIn URLs
#print champions

#cc = ChampionContact.where(:user_id => 266, :champion_id => 11) 
#print cc.inspect

#cc = ChampionContact.where(:id => 16).first
#cc.destroy

# Update LinkedIn URL
#champion = Champion.where(:email => '<insertemail>').first
#champion.linkedin_url = 'https://www.linkedin.com/in/linkedinhandle/'
#champion.save

# Find duplicate records
#champions = Champion.select(:email).group(:email).having("count(*) > 1")
#champions = Champion.select(:linkedin_url).group(:linkedin_url).having("count(*) > 1")
#print champions

# Print a bunch of Champions connections 
#ids = [1, 2, 3]
#champions_contacts = ChampionContact.where('champion_id IN (?)', ids).all
#print champions_contacts

# Print all champions and contact requests
#champion_ids = []
#ChampionContact.all.each do |cc|
#  puts ""
#  print "ChampionContact: user_id = #{cc.user_id}, champion = #{cc.champion_id}, created_at = #{cc.created_at}, fellow_survey_answered_at = #{cc.fellow_survey_answered_at}, champion_survey_answered_at = #{cc.champion_survey_answered_at}"
#  print "### ChampionContact = #{cc.inspect}" 
#  champion_ids.push(cc.champion_id)
#end
#
#champions = Champion.where('id IN (?)', champion_ids)
#champions.all.each do |champ|
#  puts ""
#  print champ.inspect
#end


# Replace all email addresses with a test email and set all Champion Contact requests to yesterday.
# DO NOT RUN THIS IN PRODUCTION!!
#Champion.all.each do |c|
#  c.email = '<inserttestemailtouse>'
#  c.save
#end
#user_ids = []
#ChampionContact.all.each do |cc|
#  user_ids.push(cc.user_id)
#  cc.created_at = 1.day.ago
#  cc.save
#end
#users = User.where('id IN (?)', user_ids)
#users.all.each do |u|
#  u.email = '<inserttestemailtouse'
#  u.save
#end
## Set two specific champions to be requested contact more than a week ago.
#cc = ChampionContact.find(17)
#cc.created_at = (2.weeks.ago)
#cc.save
#puts "#{ChampionContact.find(16).inspect}"
#puts "#{ChampionContact.find(17).inspect}"
# END VERY DANGEROUS OPERATION!!

#c = Champion.where(:email => '<insertemail>').first

#c1 = ChampionContact.where(:champion_id => c.id).first
#c1.created_at = (1.week.ago - 1)
#c1.fellow_survey_answered_at = nil
#c1.champion_survey_answered_at = nil
#c1.fellow_survey_email_sent = false
#c1.champion_survey_email_sent = false
#c1.save
#c2 = ChampionContact.find(25)
#c2.created_at = (1.week.ago - 1)
#c2.fellow_survey_answered_at = nil
#c2.champion_survey_answered_at = nil
#c2.fellow_survey_email_sent = false
#c2.champion_survey_email_sent = false
#c2.save

#ChampionContact.where("
#      ((fellow_survey_answered_at IS NULL OR champion_survey_answered_at IS NULL)
#      AND (fellow_survey_email_sent != TRUE OR champion_survey_email_sent != TRUE))
#      AND created_at < ?",
#      1.week.ago.end_of_day).each do |cc|
#  if cc.fellow_survey_answered_at.nil? && !cc.fellow_survey_email_sent
#    puts "Fellow should receive email: #{cc.inspect}"
#  end
#
#  if cc.champion_survey_answered_at.nil? && !cc.champion_survey_email_sent
#    puts "Champion should receive email: #{cc.inspect}"
#  end
#end

exit
