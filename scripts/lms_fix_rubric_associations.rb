# Login to the Canvas server and run
# cd /var/canvas/current
# sudo su canvasuser -c "RAILS_ENV=production script/rails console"

# This run this:
course_id = 29
context_code = 'course_'+course_id
course = Course.find(course_id) # SJSU
course.assignments.active.each do |assignment|
  rubric_assoc = assignment.rubric_association 
  puts "### Found rubric_association = #{rubric_assoc.inspect} for assignment = #{assignment.inspect}"
  rubric_assoc.context_id = course_id if rubric_assoc
  rubric_assoc.context_code = context_code if rubric_assoc
  rubric_assoc.save if rubric_assoc 
end
