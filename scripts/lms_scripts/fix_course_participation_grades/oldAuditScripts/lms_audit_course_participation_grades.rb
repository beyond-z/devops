# To run on production, connect to production machin and run:
# cd /var/canvas/current
# vim lms_audit_course_participation_grades.rb
# paste the contents of this file in there and save
# sudo su canvasuser -c "RAILS_ENV=production script/rails console"
# $stdout = File.new('/tmp/audit_course_participation_grades.txt', 'w')
# $stdout.sync = true
# load 'lms_audit_course_participation_grades.rb'

def audit_grades

  # Update these to the proper values that you are interesting in
  course_id = 27

  course = Course.find(course_id)
  participation_assignments =[] 
  pages = {}
  course.assignments.active.find_all { |a| a.title[/^Course Participation - .+/] }.each do |part_assignment|
    puts "### Processing #{part_assignment.title}"
    participation_assignments.push(part_assignment)
    # Can't get WikiPage from course. Need to look up its ContentTag and use that id to get the page since pages aren't directly part of a course
    tag = ContentTag.where(:context_id => course_id, :context_type => 'Course', :content_type => 'WikiPage', :title => part_assignment.title[/^Course Participation - (.+)/, 1]).first
    page = WikiPage.find(tag.content_id)
    pages[part_assignment.title] = page
  end
  puts "### Found #{participation_assignments.length} Course Participation assignments"
  puts "### Found #{pages.length} corresponding pages"

  users = {}
  course.student_enrollments.active.each do |se|
    uid = se.user_id
    next if users[uid]
    user = User.find(uid)
    wrote_username = false
    participation_assignments.each do |assignment|
      submission = assignment.submissions.where(user_id: user.id).first
      if (submission && submission.workflow_state == "graded" && submission.score && submission.score < 10)
        if (!wrote_username)
          wrote_username = true
          puts "### Auditing participation scores for: username = #{user.name}, userid = #{user.id}"
        end
        puts "### Found submission without full score, checking which fields they didn't fill out: #{submission.id} for #{assignment.title}"
        page = pages[assignment.title]
        names = {}
        missing_names = {}
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
          missing_names[n] = true if !found.any?
        end
        puts "### Missing names for this submission: #{missing_names.inspect}"
        correct_grade = (filled_count.to_f / count.to_f) * assignment.points_possible.to_f
        existing_grade = submission.score
        if (correct_grade.round(2) != existing_grade.round(2))
          submission.with_lock do
            if correct_grade > existing_grade
              puts "### UPDATING: user email = #{user.email}, assignment = '#{assignment.title}', Old score = #{submission.score}, New score = #{correct_grade}, user name = '#{user.name}', userid = #{user.id}, assignment id = #{assignment.id}, submission = #{submission.id}" #, missing fields = #{missing_names.inspect}"
              # TODO: uncomment when you're ready to run it for real
              #assignment.grade_student(user, {:grade => (correct_grade), :suppress_notification => true })
            elsif existing_grade < correct_grade
              puts "### SKIPPING: grade would be updated to be less than it is now -- user email = #{user.email}, assignment = '#{assignment.title}', Old score = #{submission.score}, New score = #{correct_grade}, user name = '#{user.name}', userid = #{user.id}, assignment id = #{assignment.id}, submission = #{submission.id}" 
            end
          end
        end
      end
    end
    users[uid] = true
  end  
  
end

audit_grades
