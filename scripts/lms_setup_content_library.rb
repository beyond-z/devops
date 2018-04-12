# Login to the Canvas server and run
# cd /var/canvas/current
# sudo su canvasuser -c "RAILS_ENV=production script/rails console"

# This run this:
        course = Course.find(25) # for 2017 Spring Braven Accelerator
	master = Course.find(1)
	course.assignments.active.each do |assignment|
		master_assignment = master.assignments.where(:title => assignment.title)
		raise "uh oh" if master_assignment.count != 1
		master_assignment = master_assignment.first
		assignment.clone_of_id = master_assignment.id
		assignment.save
	end
	course.wiki_pages.active.each do |wiki_page|
		master_wiki_page = master.wiki_pages.where(:title => wiki_page.title)
		raise "uh oh #{wiki_page.title}" if master_wiki_page.count != 1
		master_wiki_page = master_wiki_page.first
		wiki_page.clone_of_id = master_wiki_page.id
		wiki_page.save
	end
