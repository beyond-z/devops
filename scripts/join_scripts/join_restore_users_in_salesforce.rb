# To run on production:
# cd ~/src/join/ && cat ~/scripts/join_restore_users_in_salesforce.rb | heroku run rails console --app boiling-plateau-9467 --remote production
#
# TO run on staging:
# cd ~/src/join/ && cat ~/scripts/join_restore_users_in_salesforce.rb | heroku run rails console --app quiet-scrubland-9241 --remote staging

###################################
# IMPORTANT NOTE: 
# go through and set all lines with 'TODO_insert_me' to the proper values!
##################################

require 'salesforce'

def limit_size(str, max)
  if str.length > max
    return str[0...max]
  end
  str
end

def handle_na(str)
  if str == 'na' || str == 'n/a' || str == 'N/a' || str == 'N/A'
    return ''
  end
  str
end

def format_phone_for_storage(phone)
  return phone if phone.blank?
  phone.gsub(/[^0-9]/, '')
end

def sync_salesforce_contact_info(user, section_name)
  #TODO: assumes they don't exist in Salesforce. If they do, this creates a duplicate. Fix that.
  salesforce = BeyondZ::Salesforce.new
  client = salesforce.get_client
  contact = {}

  contact['FirstName'] = user.first_name.split.map(&:capitalize).join(' ')
  contact['LastName'] = user.last_name.split.map(&:capitalize).join(' ')
  contact['Email'] = user.email
#  contact['OwnerId'] = 'TODO_insert_me'
#  contact['IsUnreadByOwner'] = false
  contact['MailingCity'] = user.city   
  contact['MailingState'] = user.state
  contact['Phone'] = user.phone
  contact['BZ_User_Id__c'] = user.id
  contact['Interested_In__c'] = user.applicant_details
  contact['Signup_Date__c'] = user.created_at
  contact['Came_From_to_Visit_Site__c'] = user.external_referral_url
  contact['User_Type__c'] = user.salesforce_applicant_type
  contact['Undergrad_University__c'] = user.university_name
  contact['Anticipated_Graduation__c'] = user.anticipated_graduation
  contact['Anticipated_Graduation_Semester__c'] = user.anticipated_graduation_semester
  contact['Company__c'] = (user.company.nil? || user.company.empty?) ? "#{user.name} (individual)" : user.company
  contact['Started_College__c'] = user.started_college_in
  contact['Enrollment_Semester__c'] = user.started_college_in_semester
  contact['Interested_in_opening_BZ__c'] = user.like_to_help_set_up_program ? true : false
  contact['Keep_Informed__c'] = user.like_to_know_when_program_starts ? true : false
  contact['BZ_Region__c'] = 'Chicago'
  contact['Candidate_Status__c'] = 'Confirmed'
  contact['Section_Name_In_LMS__c'] = section_name

  contact = client.create('Contact', contact)
  user.salesforce_id = contact['Id']
  user.save!
  print "### Set Salesforce COntact Id = #{user.salesforce_id} for #{user.email}"
  user
end

def sync_salesforce_enrollment_info(enrollment, sf_id, section_name)
  #TODO: assumes they don't exist in Salesforce. If they do, this creates a duplicate. Fix that.
  cm = {}
  #cm['CampaignId'] = 'TODO_insert_me' 
  cm['Candidate_Status__c'] = ''
  cm['ContactId'] = sf_id
  
  cm['Application_Status__c'] = 'Started'
  cm['Apply_Button_Enabled__c'] = false
  cm['Application_Decision_Sent__c'] = true
  #cm['Must_Queue_Application_Reminder__c'] = false # TODO: remove me for production. 
  cm['Date_App_Submitted__c'] = enrollment.updated_at
  cm['Section_Name_In_LMS__c'] = section_name
  cm['Industry__c'] = enrollment.industry
  cm['Company__c'] = enrollment.company
  cm['Middle_Name__c'] = enrollment.middle_name
  cm['Accepts_Text__c'] = enrollment.accepts_txt
  cm['Cannot_Attend__c'] = enrollment.cannot_attend
  cm['Student_Id__c'] = enrollment.student_id
  cm['Student_Course__c'] = enrollment.student_course
  cm['Eligible__c'] = enrollment.will_be_student
  cm['GPA_Circumstances__c'] = enrollment.gpa_circumstances
  cm['Other_Commitments__c'] = enrollment.other_commitments
  cm['Grad_Degree__c'] = enrollment.grad_degree
  cm['Birthdate__c'] = enrollment.birthdate
  cm['Post_Grad__c'] = enrollment.post_graduation_plans
  cm['Why_BZ__c'] = enrollment.why_bz
  cm['Passions_Expertise__c'] = enrollment.passions_expertise
  #cm['Want_Grow_Professionally__c'] = enrollment.want_grow_professionally
  cm['Meaningful_Activity__c'] = enrollment.meaningful_activity
  cm['Relevant_Experience__c'] = enrollment.relevant_experience
  cm['Undergrad_University__c'] = enrollment.undergrad_university
  cm['Undergraduate_Year__c'] = enrollment.undergraduate_year
  cm['Anticipated_Graduation_Semester__c'] = enrollment.anticipated_graduation_semester
  cm['Major__c'] = enrollment.major
  cm['Major2__c'] = enrollment.major2
  cm['GPA__c'] = enrollment.gpa
  cm['GPA__c'] = 'NA' if enrollment.gpa.blank? || enrollment.gpa == '0'
  cm['Started_College__c'] = enrollment.enrollment_year
  cm['Enrollment_Semester__c'] = enrollment.enrollment_semester
  cm['Is_Graduate_Student__c'] = enrollment.is_graduate_student
  cm['Previous_University__c'] = enrollment.previous_university
  cm['High_School__c'] = enrollment.high_school
  cm['Languages__c'] = enrollment.languages
  cm['Sourcing_Info__c'] = enrollment.sourcing_info
  cm['Available_Meeting_Times__c'] = enrollment.meeting_times
  cm['Additional_Comments__c'] = enrollment.comments
  cm['Grad_University__c'] = enrollment.grad_school
  cm['Graduate_Year__c'] = enrollment.anticipated_grad_school_graduation
  cm['Digital_Footprint__c'] = limit_size(enrollment.digital_footprint, 200)
  cm['Digital_Footprint_2__c'] = limit_size(enrollment.digital_footprint2, 200)
  cm['Resume__c'] = enrollment.resume.url if enrollment.resume.present?
  cm['Reference_1_Name__c'] = enrollment.reference_name
  cm['Reference_1_How_Known__c'] = enrollment.reference_how_known
  cm['Reference_1_How_Long_Known__c'] = enrollment.reference_how_long_known
  cm['Reference_1_Email__c'] = handle_na(enrollment.reference_email)
  cm['Reference_1_Phone__c'] = format_phone_for_storage(handle_na(enrollment.reference_phone))
  cm['Reference_2_Name__c'] = enrollment.reference2_name
  cm['Reference_2_How_Known__c'] = enrollment.reference2_how_known
  cm['Reference_2_How_Long_Known__c'] = enrollment.reference2_how_long_known
  cm['Reference_2_Email__c'] = handle_na(enrollment.reference2_email)
  cm['Reference_2_Phone__c'] = format_phone_for_storage(handle_na(enrollment.reference2_phone))
  cm['African_American__c'] = enrollment.bkg_african_americanblack
  cm['Asian_American__c'] = enrollment.bkg_asian_american
  cm['Latino__c'] = enrollment.bkg_latino_or_hispanic
  cm['Native_Alaskan__c'] = enrollment.bkg_native_alaskan
  cm['Native_American__c'] = enrollment.bkg_native_american_american_indian
  cm['Native_Hawaiian__c'] = enrollment.bkg_native_hawaiian
  cm['Pacific_Islander__c'] = enrollment.bkg_pacific_islander
  cm['White__c'] = enrollment.bkg_whitecaucasian
  cm['Multi_Ethnic__c'] = enrollment.bkg_multi_ethnicmulti_racial
  cm['Identify_As_Person_Of_Color__c'] = enrollment.identify_poc
  cm['Identify_As_Low_Income__c'] = enrollment.identify_low_income
  cm['Identify_As_First_Gen__c'] = enrollment.identify_first_gen
  cm['Other_Race__c'] = enrollment.bkg_other
  cm['Hometown__c'] = enrollment.hometown
  cm['Pell_Grant_Recipient__c'] = enrollment.pell_grant
  cm['Study_Abroad__c'] = enrollment.study_abroad
  cm['Gender_Identity__c'] = enrollment.gender_identity

  # Can't use client.materialize because it sets the checkboxes to nil
  # instead of false which fails server-side validation. This method
  # works though.
  sf = BeyondZ::Salesforce.new
  client = sf.get_client
  cm = client.create('CampaignMember', cm)
  cm.Application_Status__c = 'Submitted' # Update the CampaignMember so the trigger runs that dequeues the intro email
  cm.save
  cm.Candidate_Status__c = 'Accepted' # Ditto on above, but for deleting the "Review application" task
  cm.save
  cm.Candidate_Status__c = 'Confirmed' # Ditto on above, but for deleting the "Review application" task
  cm.save
  cm
end

# TODO_insert_me -- set the array below and uncomment to run
#users_to_fix = [
#{:email => 'TODO_insert_me', :section_name => 'TODO_insert_me e.g. NLU SomeFirstName (We)'},
#{:email => 'TODO_insert_me', :section_name => 'TODO_insert_me e.g. NLU SomeFirstName (We)'}]

users_to_fix.each do |user_to_fix|

  u = User.find_by_email(user_to_fix[:email])
  if u
    u = sync_salesforce_contact_info(u, user_to_fix[:section_name])
    enrollment = Enrollment.latest_for_user(u.id)
    if enrollment
      cm = sync_salesforce_enrollment_info(enrollment, u.salesforce_id, user_to_fix[:section_name])
    else
      print "### No enrollment found for: #{u.email}"
    end
  else
    print "### User not found: #{email}"
  end
end
