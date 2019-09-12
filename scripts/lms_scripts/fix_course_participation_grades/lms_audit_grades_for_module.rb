# To run on production, connect to production machin and run:
# cd /var/canvas/current
# vim lms_audit_grades_for_module.rb
# paste the contents of this file in there and save
# sudo su canvasuser -c "RAILS_ENV=production script/rails console"
# $stdout = File.new('/tmp/audit_grades_for_module.txt', 'w')
# $stdout.sync = true
# load 'lms_audit_grades_for_module.rb'

def audit_grades_for_module

  # Update these to the proper values that you are interesting in
  module_item_id = 4471
  course_id = 39
  module_name = 'Network Like a Pro'

  tag = ContentTag.where(:id => module_item_id, :context_id => course_id, :context_type => 'Course', :content_type => 'WikiPage').first
  page = WikiPage.find(tag.content_id)
  course = Course.find(course_id)
  get_the_page_id = page.id
  participation_assignment = course.assignments.active.where(:title => "Course Participation - #{module_name}").first

  puts "### VIEWIING COURSE PARTICIPATION GRADES FOR: https://portal.bebraven.org/courses/#{course_id}/pages/#{page.url}?module_item_id=#{module_item_id}"

  users = {}
  course.student_enrollments.active.each do |se|
    uid = se.user_id
    next if users[uid]
    user = User.find(uid)
    wrote_username = false
    submission = participation_assignment.submissions.where(user_id: user.id).first
    if (submission && submission.workflow_state == "graded" && submission.score)
      if (!wrote_username)
        wrote_username = true
        puts "### Auditing participation scores for: username = #{user.name}, userid = #{user.id}"
      end
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
        puts "### name = #{found.inspect}"
      end
      # TODO: deal with mastery questions too
      puts "### names = #{names.inspect}, missing_names = #{missing_names.inspect}"
    end
  end
end

audit_grades_for_module
