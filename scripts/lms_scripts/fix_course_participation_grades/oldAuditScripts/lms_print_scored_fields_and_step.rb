# To run on production, connect to production machin and run:
# cd /var/canvas/current
# vim lms_print_scored_fields_and_step.rb
# paste the contents of this file in there and save
# sudo su canvasuser -c "RAILS_ENV=production script/rails console"
# $stdout = File.new('/tmp/print_scored_fields_and_step.txt', 'w')
# $stdout.sync = true
# load 'lms_print_scored_fields_and_step.rb'

def print_grade_info

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

  participation_assignments.each do |assignment|
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
        next if o.attr('type') == 'checkbox' && o.attr('data-bz-answer').nil? # checkboxes count if there is an answer
        names[n] = true
        count += 1
      end
      puts "### for #{assignment.title} the count of fields to consider is #{count.to_f}"
      puts "### for each field you fill out (for pur participation) or get right (for mastery), you get #{assignment.points_possible.to_f / count.to_f} added to your grade"
  end
  
end

print_grade_info
