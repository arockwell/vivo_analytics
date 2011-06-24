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
    puts "Running query: #{query_location}"
    run_query(query_location)
  end
end

QUERY_BASE_DIR = File.expand_path(File.dirname(__FILE__)) + "/tag_entity_constructs"

query_files = { :role => "#{QUERY_BASE_DIR}/RoleQuery.sparql",
  :date_time_interval => "#{QUERY_BASE_DIR}/DateTimeInterval.sparql",
  :co_pi_stub => "#{QUERY_BASE_DIR}/CoPIStubQuery.sparql",
  :pi_stub => "#{QUERY_BASE_DIR}/PIStubQuery.sparql",
  :organization_administer => "#{QUERY_BASE_DIR}/OrganizationAdminister.sparql",
  :organization_award => "#{QUERY_BASE_DIR}/OrganizationAward.sparql",
  :organization_sub_contracted => "#{QUERY_BASE_DIR}/OrganizationSubContracted.sparql",
  :grant_query => "#{QUERY_BASE_DIR}/GrantQuery.sparql",
}

tag_for_deletion_by_subject_file = "#{QUERY_BASE_DIR}/TagForDeletionSubject.sparql"
tag_for_deletion_by_object_file = "#{QUERY_BASE_DIR}/TagForDeletionObject.sparql"
vivo_main_model = "/usr/share/vivo/harvester/config/models/vivo.xml"
vivo_inferences_model = "/usr/share/vivo/harvester/config/models/vivo_inferences.xml"
vivo_inferences_scratchpad_model = "/usr/share/vivo/harvester/config/models/vivo_inferences_scratchpad.xml"

query_tasks = []
query_files.each do |query_name, query_file|
  query_tasks << create_query_task(query_name, query_file)
end

desc "Query all entities"
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

desc "Add deletion tag for all entities"
task :add_deletion_tag_for_all_entities => add_deletion_tag_tasks

desc "Find all statements related to entities of rdf:type ufVivo:tagForDeletion"
task :run_query_tag_for_deletion do
  puts "Perofrming run_query_tag_for_deletion"
  system("date")
  run_query(tag_for_deletion_by_subject_file)
  system("date")
  run_query(tag_for_deletion_by_object_file)
end

desc "Delete all entities from all models"
task :delete_all_entities => [:run_query_tag_for_deletion, :delete_all_entities_from_main_model, :delete_all_entities_from_inferencing_models]

desc "Delete all entities from main model"
task :delete_all_entities_from_main_model do
  puts "Performing delete_all_entities_from_main_model"
  delete_all_tag_for_deletion_entities(tag_for_deletion_by_subject_file, tag_for_deletion_by_object_file, vivo_main_model)
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

count_entity_queries = {
  :count_dsr_orgs => "#{QUERY_BASE_DIR}/count_dsr_orgs.sparql",
  :count_dsr_people => "#{QUERY_BASE_DIR}/count_dsr_people.sparql",
  :count_dsr_grants => "#{QUERY_BASE_DIR}/count_dsr_grants.sparql"
}
count_entity_tasks = []
count_entity_queries.each do |query_name, query_location|
  count_entity_tasks << create_query_task(query_name, query_location)
end

desc "Print counts of all entities that might have a ufVivo:harvestedBy tag"
task :count_entities => count_entity_tasks do
  count_entity_queries.each do |query_name, query_location|
    puts query_name
    system("cat #{query_location}.nt")
  end
end

stray_queries = {
  :stray_co_pi_role => "#{QUERY_BASE_DIR}/FindStrayhasCoPIRole.sparql",
  :stray_pi_role => "#{QUERY_BASE_DIR}/FindStrayhasPIRole.sparql",
  :stray_administers_grant => "#{QUERY_BASE_DIR}/FindStrayAdministersGrant.sparql"
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
