# To run on production, connect to production machin and run:
# cd /var/canvas/current
# vim lms_audit_grade_for_student.rb
# paste the contents of this file in there and save
# sudo su canvasuser -c "RAILS_ENV=production script/rails console"
# $stdout = File.new('/tmp/audit_grade_for_student.txt', 'w')
# $stdout.sync = true
# load 'lms_audit_grade_for_student.rb'

def audit_grade_for_student

  # Update these to the proper values that you are interesting in
  student_id = 1272
  module_item_id = 3772
  course_id = 27
  module_name = 'Network Like a Pro'

  tag = ContentTag.where(:id => module_item_id, :context_id => course_id, :context_type => 'Course', :content_type => 'WikiPage').first
  page = WikiPage.find(tag.content_id)
  course = Course.find(course_id)
  get_the_page_id = page.id
  participation_assignment = course.assignments.active.where(:title => "Course Participation - #{module_name}").first
  user = User.find(student_id)
  puts "### Auditing participation and mastery score for: username = #{user.name}, userid = #{user.id}, https://portal.bebraven.org/courses/#{course_id}/pages/#{page.url}?module_item_id=#{module_item_id}"
  
  se = course.student_enrollments.active.where(:user_id => student_id).first
  uid = se.user_id
  submission = participation_assignment.submissions.where(user_id: user.id).first
  names = {}
  missing_names = {}
  wrong_answer_names = {}
  count = 0
  filled_and_correct_count = 0
  selector = 'input[data-bz-retained]:not(.bz-optional-magic-field),textarea[data-bz-retained]:not(.bz-optional-magic-field)'
  page_html = page.body
  doc = Nokogiri::HTML(page_html)
  doc.css(selector).each do |o|
    n = o.attr('data-bz-retained')
    next if names[n]
    mastery_answer = o.attr('data-bz-answer')
    next if o.attr('type') == 'checkbox' && mastery_answer.nil?
    names[n] = true
    count += 1
    found = RetainedData.where(:user_id => uid, :name => n)
    if found.any?
      if !mastery_answer.nil? # The field must have the correct answer to count
        if !mastery_answer.blank? && mastery_answer == found.first.value
          filled_and_correct_count += 1
          puts "### for #{n}, mastery answer = #{mastery_answer} is correct. Adding 1 step." 
        elsif mastery_answer.blank? && (found.first.nil? || found.first.value.blank?)
          filled_and_correct_count += 1 # If the checkbox isn't supposed to be checked, make sure it's not
          puts "### for #{n}, mastery answer = #{mastery_answer} is correct. Adding 1 step." 
        else
          wrong_answer_names[n] = true
          puts "### for #{n}, mastery answer = #{mastery_answer} is incorrect. Subtracting 1 step." 
        end
      else # Just a participation field, count it.
        filled_and_correct_count += 1
          puts "### for #{n}, participation credit. Adding 1 step." 
      end
    else
      if mastery_answer.nil?
        missing_names[n] = true
        puts "### for #{n}, no partcipation. Subtracting 1 step." 
      else
        if mastery_answer.blank?
          filled_and_correct_count += 1 # If we don't find the name but the answer is blank, that's correct.
          puts "### for #{n}, mastery answer = #{mastery_answer} is correct. Adding 1 step." 
        else
          wrong_answer_names[n] = true
          puts "### for #{n}, mastery answer = #{mastery_answer} is incorrect. Subtracting 1 step." 
        end
      end
    end
  end
  puts "### Missing names for this submission: #{missing_names.inspect}"
  puts "### Incorrect master answer names for this submission: #{wrong_answer_names.inspect}"
  step = participation_assignment.points_possible.to_f / count.to_f
  correct_grade = (filled_and_correct_count.to_f / count.to_f) * participation_assignment.points_possible.to_f
  existing_grade = submission.score
  puts "### AUDIT: step = #{step}, correct_grade = #{correct_grade}, existing_grade = #{existing_grade}"
 
end

audit_grade_for_student
