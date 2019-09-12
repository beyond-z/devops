# To run on production, connect to production machin and run:
# cd /var/canvas/current
# vim lms_view_missing_course_participation_fields.rb
# paste the contents of this file in there and save
# sudo su canvasuser -c "RAILS_ENV=production script/rails console"
# $stdout = File.new('/tmp/view_missing_course_participation_fields.txt', 'w')
# $stdout.sync = true
# load 'lms_view_missing_course_participation_fields.rb'

def view_missing_fields

  # Update these to the proper values that you are interesting in
  student_id = 1321
  module_item_id = 3772
  course_id = 27
  module_name = 'Network Like a Pro'

  tag = ContentTag.where(:id => module_item_id, :context_id => course_id, :context_type => 'Course', :content_type => 'WikiPage').first
  page = WikiPage.find(tag.content_id)
  course = Course.find(course_id)
  get_the_page_id = page.id
  participation_assignment = course.assignments.active.where(:title => "Course Participation - #{module_name}").first

  puts "### VIEWIING MISSING FIELDS IN COURSE PARTICIPATION GRADES FOR: https://portal.bebraven.org/courses/#{course_id}/pages/#{page.url}?module_item_id=#{module_item_id}"


 user = User.find(student_id)
 puts "### username = #{user.name}, userid = #{user.id},"
 se = course.student_enrollments.active.where(:user_id => student_id).first
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
   found = RetainedData.where(:user_id => student_id, :name => n) 
   filled_count += 1 if found.any?
   missing_names[n] = true if !found.any?
 end

 puts "### names = #{names.inspect}, missing_names = #{missing_names.inspect}"

end

view_missing_fields
