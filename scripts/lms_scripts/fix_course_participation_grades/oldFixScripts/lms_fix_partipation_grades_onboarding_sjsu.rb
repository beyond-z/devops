# To run on production, connect to production machin and run:
# cd /var/canvas/current
# vim fix_grades_sjsu_onboarding.rb
# paste the contents of this file in there and save
# sudo su canvasuser -c "RAILS_ENV=production script/rails console"
# $stdout = File.new('/tmp/fix_grades_sjsu_onboarding.txt', 'w')
# $stdout.sync = true
# load 'fix_grades_sjsu_onboarding.rb'

def fix_grades

  module_item_id = 3767
  course_id = 27
  module_name = 'Onboard to Braven'
  
  tag = ContentTag.where(:id => module_item_id, :context_id => course_id, :context_type => 'Course', :content_type => 'WikiPage').first
  page = WikiPage.find(tag.content_id)
  course = Course.find(course_id)
  get_the_page_id = page.id
  participation_assignment = course.assignments.active.where(:title => "Course Participation - #{module_name}").first

  puts "### FIXING UP COURSE PARTICIPATION GRADES FOR: https://portal.bebraven.org/courses/#{course_id}/pages/#{page.url}?module_item_id=#{module_item_id}"

  users = {}

  course.student_enrollments.active.each do |se|
    uid = se.user_id
    next if users[uid]
    user = User.find(uid)
    puts "### username = #{user.name}, userid = #{user.id},"
    names = {}
    count = 0
    filled_count = 0
    selector = 'input[data-bz-retained]:not(.bz-optional-magic-field),textarea[data-bz-retained]:not(.bz-optional-magic-field)'  
    page_html = page.body
    doc = Nokogiri::HTML(page_html) 
    doc.css(selector).each do |o|
      n = o.attr('data-bz-retained')
      next if names[n]
      next if o.attr('type') == 'checkbox'
      names[n] = true
      count += 1
      found = RetainedData.where(:user_id => uid, :name => n)
      filled_count += 1 if found.any?
    end

    submission = participation_assignment.find_or_create_submission(user)
    existing_grade = submission.grade.nil? ? 0 : submission.grade.to_f
    submission.with_lock do
      new_grade = (filled_count.to_f / count.to_f) * participation_assignment.points_possible.to_f
      if (new_grade > (participation_assignment.points_possible.to_f - 0.4))
        new_grade = participation_assignment.points_possible.to_f
      end

      if new_grade > existing_grade
        puts "### #{user.name}: Updating grade - Old grade = #{existing_grade}, New grade = #{new_grade}"
        participation_assignment.grade_student(user, {:grade => (new_grade), :suppress_notification => true })
      elsif existing_grade < new_grade
        puts "### #{user.name}: Skipping - grade would be updated to be less than it is now. Old grade = #{existing_grade}, New grade = #{new_grade}"
      else
        puts "### #{user.name}: Skipping - grade hasn't changed. Old grade = #{existing_grade}, New grade = #{new_grade}"
      end
    end
    users[uid] = true

  end

end

fix_grades
