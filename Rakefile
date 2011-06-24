#!/usr/bin/ruby

def run_query(query_file, type='N-TRIPLES')
  system("bash", "-c", "cd /usr/share/vivo/harvester; source /usr/share/vivo/harvester/scripts/env; $JenaConnect -j $VIVOCONFIG -JcheckEmpty=$CHECKEMPTY -Q #{type} -q \"`cat #{query_file}`\" > #{query_file}.nt")
end

def add_file(input_file, type='N-TRIPLES')
  system("bash", "-c", "cd /usr/share/vivo/harvester; source /usr/share/vivo/harvester/scripts/env; $Transfer -o $VIVOCONFIG -OcheckEmpty=$CHECKEMPTY -R #{type} -r #{input_file}")
end

def remove_rdf_file(input_file, type='N-TRIPLES')
  system("bash", "-c", "cd /usr/share/vivo/harvester; source /usr/share/vivo/harvester/scripts/env; $Transfer -o $VIVOCONFIG -OcheckEmpty=$CHECKEMPTY -R #{type} -r #{input_file} -m")
end

def remove_rdf_file_from_model(input_file, model_config_file, type='N-TRIPLES')
  system("bash", "-c", "cd /usr/share/vivo/harvester; source /usr/share/vivo/harvester/scripts/env; $Transfer -o #{model_config_file} -OcheckEmpty=$CHECKEMPTY -R #{type} -r #{input_file} -m")
end

def delete_all_tag_for_deletion_entities(subject_file, object_file, model_config_file, type='N-TRIPLES')
  system("date")
  remove_rdf_file("#{subject_file}.nt")
  system("date")
  remove_rdf_file("#{object_file}.nt")
end

def create_query_task(query_name, query_location)
  task_name = "query_#{query_name}".intern
  desc "Run #{query_location}"
  task task_name do
    system("date")
    puts "Performing #{task_name}"
    puts "Running query: #{query_file}"
    run_query(query_file)
  end
end

query_files = { :role => "~/dev/remove_data/tag_entity_constructs/RoleQuery.sparql",
  :date_time_interval => "~/dev/remove_data/tag_entity_constructs/DateTimeInterval.sparql",
  :co_pi_stub => "~/dev/remove_data/tag_entity_constructs/CoPIStubQuery.sparql",
  :pi_stub => "~/dev/remove_data/tag_entity_constructs/PIStubQuery.sparql",
  :organization_administer => "~/dev/remove_data/tag_entity_constructs/OrganizationAdminister.sparql",
  :organization_award => "~/dev/remove_data/tag_entity_constructs/OrganizationAward.sparql",
  :organization_sub_contracted => "~/dev/remove_data/tag_entity_constructs/OrganizationSubContracted.sparql",
  :grant_query => "~/dev/remove_data/tag_entity_constructs/GrantQuery.sparql",
}

tag_for_deletion_by_subject_file = "~/dev/remove_data/tag_entity_constructs/TagForDeletionSubject.sparql"
tag_for_deletion_by_object_file = "~/dev/remove_data/tag_entity_constructs/TagForDeletionObject.sparql"
vivo_main_model = "/usr/share/vivo/harvester/config/models/vivo.xml"
vivo_inferences_model = "/usr/share/vivo/harvester/config/models/vivo_inferences.xml"
vivo_inferences_scratchpad_model = "/usr/share/vivo/harvester/config/models/vivo_inferences_scratchpad.xml"

query_tasks = []
query_files.each do |query_name, query_file|
  query_tasks << create_query_task(query_name, query_file)
end

task :query_all_entities => query_tasks

add_deletion_tag_tasks = []
query_files.each do |query_name, query_file|
  task_name = "add_deletion_tag_#{query_name}".intern 
  add_deletion_tag_tasks << task_name
  task task_name => [ "query_#{query_name}".intern ]do
    system("date")
    puts "Performing #{task_name}"
    puts "Adding data in: #{query_file}.nt"
    add_file("#{query_file}.nt")
  end
end

task :add_deletion_tag_for_all_entities => add_deletion_tag_tasks

task :delete_all_entities => [:run_query_tag_for_deletion, :delete_all_entities_from_main_model, :delete_all_entities_from_inferencing_models]

task :delete_all_entities_from_main_model do
  puts "Performing delete_all_entities_from_main_model"
  delete_all_tag_for_deletion_entities(tag_for_deletion_by_subject_file, tag_for_deletion_by_object_file, vivo_main_model)
end

task :run_query_tag_for_deletion do
  puts "Perofrming run_query_tag_for_deletion"
  system("date")
  run_query(tag_for_deletion_by_subject_file)
  system("date")
  run_query(tag_for_deletion_by_object_file)
end

# Inferencing tasks _cannot_ rerun run_query_tag_for_deletion, because this will not have data in it
task :delete_all_entities_from_inferencing_models => [:delete_from_inf, :delete_from_inf_scratchpad ]

task :delete_from_inf do
  puts "Performing delete_from_inf"
  delete_all_tag_for_deletion_entities(tag_for_deletion_by_subject_file, tag_for_deletion_by_object_file, vivo_inferences_model)
end

task :delete_from_inf_scratchpad do
  puts "Performing delete_from_inf_scratchpad"
  delete_all_tag_for_deletion_entities(tag_for_deletion_by_subject_file, tag_for_deletion_by_object_file, vivo_inferences_scratchpad_model)
end

task :count_entities do
  system("date")
  puts "Orgs"
  run_query("~/dev/remove_data/tag_entity_constructs/count_orgs.sparql")
  system("cat ~/dev/remove_data/tag_entity_constructs/count_orgs.sparql.nt")
  puts "People"
  system("date")
  run_query("~/dev/remove_data/tag_entity_constructs/count_people.sparql")
  system("cat ~/dev/remove_data/tag_entity_constructs/count_people.sparql.nt")
  puts "Grants"
  system("date")
  run_query("~/dev/remove_data/tag_entity_constructs/count_grants.sparql")
  system("cat ~/dev/remove_data/tag_entity_constructs/count_grants.sparql.nt")
end

stray_queries = {
  :stray_co_pi_role => "~/dev/remove_data/tag_entity_constructs/FindStrayhasCoPIRole.sparql",
  :stray_pi_role => "~/dev/remove_data/tag_entity_constructs/FindStrayhasPIRole.sparql",
  :stray_administers_grant => "~/dev/remove_data/tag_entity_constructs/FindStrayAdministersGrant.sparql"
}

stray_query_tasks = []
stray_queries.each do |query_name, query_location|
  stray_query_tasks = create_query_task(query_name, query_location)
end

desc "Find all stray roles"
task :query_stray_entities => stray_query_tasks

desc "Add deletion tag for stray entities"
task :add_deletion_tag_for_stray_entities do
  system("date")
  add_file("#{stray_co_pi_role}.nt")
  system("date")
  add_file("#{stray_pi_role}.nt")
  system("date")
  add_file("#{stray_administers_grant}.nt")
end
