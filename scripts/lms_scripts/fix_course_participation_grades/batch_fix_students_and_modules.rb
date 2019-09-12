# This script should be customized before run - adjust course id(s), adjust name(s)
# adjust page name(s), maybe use the loop for specific people instead of for everyone.

def execute_grade_fix
  bzg = BZGrading.new

  #[56, 57, 58].each do |course_id|
  [57].each do |course_id|
  #course_id = 56 # 57 58
  #user_names = [
	#'Rebecca Winslow'
  #]

  wiki_page_names = [
	'Capstone Challenge Kickoff'
  ]

  results = []

  #user_names.each do |user_name|
  Course.find(course_id).students.active.each do |current_user|
    #current_user = User.active.find_by_name(user_name)
    raise Exception.new "#{user_name} not exist" if current_user.nil?
    wiki_page_names.each do |wiki_page_name|

      module_item_id = bzg.find_module_item_id(course_id, wiki_page_name)

      # calculate existing score and audit trace
      response_object = bzg.calculate_user_module_score(module_item_id, current_user)

      score = 0.0
      response_object["audit_trace"].each do |at|
	#results << "#{at["points_given"]} #{at["points_amount"]} #{at["points_possible"]} via #{at["points_reason"]}"
	# if at["points_amount"] == at["points_amount_if_on_time"]
        if at["points_amount"] != 0
          score += at["points_amount"]
        elsif at["points_reason"] == "past_due"
          score += at["points_possible"] # allow for past due
        end
      end


      cm = bzg.get_context_module(module_item_id)
      participation_assignment = bzg.get_participation_assignment(cm.course, cm)
      submission = participation_assignment.find_or_create_submission(current_user)
      existing_grade = submission.grade.nil? ? 0 : submission.grade.to_f

      if score > existing_grade
        # save it back only if increased; to protect against complaints
        bzg.set_user_grade_for_module(module_item_id, current_user, score)
      	results << "#{current_user.name} #{wiki_page_name} updated to #{score}"
      else
      	results << "#{current_user.name} #{wiki_page_name} NOT updated to #{score}"
      end

    end
  end

  results.each do |result|
    puts result
  end

  nil
end
end
