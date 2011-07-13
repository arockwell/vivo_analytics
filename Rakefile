#!/usr/bin/ruby

QUERY_BASE_DIR = File.expand_path(File.dirname(__FILE__)) + "/tag_entity_constructs"

def run_query(query_file, type='N-TRIPLES')
  system("bash", "-c", "cd /usr/share/vivo/harvester; source /usr/share/vivo/harvester/scripts/env; $JenaConnect -j $VIVOCONFIG -JcheckEmpty=$CHECKEMPTY -Q #{type} -q \"`cat #{query_file}`\" > #{query_file}.nt")
end

def run_query_string(query_string, output_file, type='N-TRIPLES')
  system("bash", "-c", "cd /usr/share/vivo/harvester; source /usr/share/vivo/harvester/scripts/env; $JenaConnect -j $VIVOCONFIG -JcheckEmpty=$CHECKEMPTY -Q #{type} -q \"#{query_string}\" > #{output_file}")
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

def create_construct_task(query_name, query_location)
  task_name = "query_#{query_name}".intern
  desc "Run #{query_location}"
  task task_name do
    system("date")
    puts "Performing #{task_name}"
    puts "Running query: #{query_location}"
    run_query(query_location)
  end
end

def create_select_task(query_name, query_location)
  task_name = "query_#{query_name}".intern
  desc "Run #{query_location}"
  task task_name do
    system("date")
    puts "Performing #{task_name}"
    puts "Running query: #{query_location}"
    run_query(query_location)
    system("cat #{query_location}.nt")
  end
end

def create_add_rdf_task(query_name, query_location)
  desc "Add rdf from #{query_location}.nt"
  task query_name => [ "query_#{query_name}".intern ] do
    system("date")
    puts "Adding rdf in: #{query_location}.nt"
    add_file("#{query_location}.nt")
  end
end

def generate_type_count_task(query_name, type)
  sparql = <<-EOH
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

select count(?uri)
where
{
  ?uri rdf:type <#{type}>
}
  EOH
  task_name = "query_#{query_name}".intern
  desc "Run count of: #{type}"
  task task_name do
    system("date")
    puts "Performing #{task_name}"
    puts "Running query: #{query_name}"
    run_query_string(sparql, "#{QUERY_BASE_DIR}/#{query_name}.nt")
    system("cat #{QUERY_BASE_DIR}/#{query_name}.nt")
  end
end

def generate_stray_predicate_count_task(query_name, predicate)
  sparql = <<-EOH
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

select count(?x)
where
{
 ?x <#{predicate}> ?y .
 optional { ?y rdf:type ?type }
 filter(!bound(?type))
} 
EOH
  task_name = "query_#{query_name}".intern
  desc "Run count of stray: #{predicate}"
  task task_name do 
    system("date")
    puts "Performing #{task_name}"
    puts "Running query: #{query_name}"
    result_location = "#{QUERY_BASE_DIR}/#{query_name}.txt"
    run_query_string(sparql, result_location)
    system("cat #{result_location}")
  end
end

query_files = { :role => "#{QUERY_BASE_DIR}/RoleQuery.sparql",
  :date_time_interval => "#{QUERY_BASE_DIR}/DateTimeInterval.sparql",
  :person_stub => "#{QUERY_BASE_DIR}/PersonStubQuery.sparql",
  :organization_administer => "#{QUERY_BASE_DIR}/OrganizationAdminister.sparql",
  :organization_award => "#{QUERY_BASE_DIR}/OrganizationAward.sparql",
  :organization_sub_contracted => "#{QUERY_BASE_DIR}/OrganizationSubContracted.sparql",
  :organization_dsr => "#{QUERY_BASE_DIR}/OrganizationDsr.sparql",
  :grant_query => "#{QUERY_BASE_DIR}/GrantQuery.sparql",
  :stray_co_pi_role => "#{QUERY_BASE_DIR}/FindStrayhasCoPIRole.sparql",
  :stray_pi_role => "#{QUERY_BASE_DIR}/FindStrayhasPIRole.sparql",
  :stray_administers_grant => "#{QUERY_BASE_DIR}/FindStrayAdministersGrant.sparql"
}

tag_for_deletion_by_subject_file = "#{QUERY_BASE_DIR}/TagForDeletionSubject.sparql"
tag_for_deletion_by_object_file = "#{QUERY_BASE_DIR}/TagForDeletionObject.sparql"
vivo_main_model = "/usr/share/vivo/harvester/config/models/vivo.xml"
vivo_inferences_model = "/usr/share/vivo/harvester/config/models/vivo_inferences.xml"
vivo_inferences_scratchpad_model = "/usr/share/vivo/harvester/config/models/vivo_inferences_scratchpad.xml"

query_tasks = []
query_files.each do |query_name, query_file|
  query_tasks << create_construct_task(query_name, query_file)
end

desc "Query all entities"
task :query_all_entities => query_tasks

namespace :add do
  add_deletion_tag_tasks = []
  query_files.each do |query_name, query_file|
    add_deletion_tag_tasks << create_add_rdf_task(query_name, query_file)
  end

  desc "Add deletion tag for all entities"
  task :all_deletion_tags => add_deletion_tag_tasks

end

desc "Find all statements related to entities of rdf:type ufVivo:tagForDeletion"
task :run_query_tag_for_deletion do
  puts "Perofrming run_query_tag_for_deletion"
  system("date")
  run_query(tag_for_deletion_by_subject_file)
  system("date")
  run_query(tag_for_deletion_by_object_file)
end

namespace :delete do
  desc "Delete all entities from all models"
  task :all_entities_from_all_models => [:run_query_tag_for_deletion, :all_entities_from_main_model, :all_entities_from_inferencing_models]

  desc "Delete all entities from main model"
  task :all_entities_from_main_model do
    puts "Performing delete_all_entities_from_main_model"
    delete_all_tag_for_deletion_entities(tag_for_deletion_by_subject_file, tag_for_deletion_by_object_file, vivo_main_model)
  end

  # Inferencing tasks _cannot_ rerun run_query_tag_for_deletion, because this will not have data in it
  task :all_entities_from_inferencing_models do
    puts "Performing delete_from_inf"
    delete_all_tag_for_deletion_entities(tag_for_deletion_by_subject_file, tag_for_deletion_by_object_file, vivo_inferences_model)
    puts "Performing delete_from_inf_scratchpad"
    delete_all_tag_for_deletion_entities(tag_for_deletion_by_subject_file, tag_for_deletion_by_object_file, vivo_inferences_scratchpad_model)
  end

end

namespace :reverse do
  additions_file = "/usr/share/vivo/harvester/harvested-data/dsr/additions.rdf.xml"
  xml_rdf_type = "RDF\/XML"
 
  desc "Remove additions file"
  task :remove_additions_file do
    remove_rdf_file(additions_file, xml_rdf_type)
  end

  desc "Add additions file"
  task :add_additions_file do
    add_file(additions_file, xml_rdf_type)
  end
end
   
namespace :verify do
  count_entities = {
    :count_faculty => "http://vivoweb.org/ontology/core#FacultyMember",
    :count_courtesy_faculty => "http://vivo.ufl.edu/ontology/vivo-ufl/CourtesyFaculty",
    :count_librarian =>"http://vivoweb.org/ontology/core#Librarian",
    :count_non_academic =>"http://vivoweb.org/ontology/core#NonAcademic",
    :count_non_faculty_academic =>"http://vivoweb.org/ontology/core#NonFacultyAcademic",
    :count_emeritus_professor => "http://vivoweb.org/ontology/core#EmeritusProfessor",
    :count_grant => "http://vivoweb.org/ontology/core#Grant",
    :count_agreement => "http://vivoweb.org/ontology/core#Agreement",
    :count_organization => "http://xmlns.com/foaf/0.1/Organization"
  }
  count_entity_tasks = []
  count_entities.each do |query_name, type|
    count_entity_task = generate_type_count_task(query_name, type)
    count_entity_tasks << count_entity_task
  end

  namespace :dsr do
    count_dsr_entity_queries = {
      :count_dsr_orgs => "#{QUERY_BASE_DIR}/count_dsr_orgs.sparql",
      :count_dsr_people => "#{QUERY_BASE_DIR}/count_dsr_people.sparql",
      :count_dsr_grants => "#{QUERY_BASE_DIR}/count_dsr_grants.sparql"
    }
    count_dsr_entity_tasks = []
    count_dsr_entity_queries.each do |query_name, query_location|
      count_dsr_entity_tasks << create_select_task(query_name, query_location)
    end

    desc "Print counts of all entities that might have a ufVivo:harvestedBy tag"
    task :all => count_dsr_entity_tasks
    count_entity_tasks = count_entity_tasks + count_dsr_entity_tasks

  end

  namespace :stray do
    count_stray = {
      :person_in_position => "http://vivoweb.org/ontology/core#personInPosition",
      :organization_for_position => "http://vivoweb.org/ontology/core#organizationForPosition",
      :administers_grant => "http://vivoweb.org/ontology/core#administers",
      :has_co_principal_investigator_role => "http://vivoweb.org/ontology/core#hasCo-PrincipalInvestigatorRole",
      :has_principal_investigator_role => "http://vivoweb.org/ontology/core#hasPrincipalInvestigatorRole"
    }
    count_stray_tasks = []
    count_stray.each do |query_name, pred|
      count_stray_task = generate_stray_predicate_count_task(query_name, pred)
      count_stray_tasks << count_stray_task
    end
    
    desc "Print counts of all stray predicates"
    task :all => count_stray_tasks
    count_entity_tasks = count_entity_tasks + count_stray_tasks
  end
  namespace :duplicate do
    duplicates = {
      :duplicate_org_labels => "#{QUERY_BASE_DIR}/find_duplicate_org_labels.sparql"
    }
    duplicate_tasks = []
    duplicates.each do |query_name, query_location|
      duplicate_task = create_select_task(query_name, query_location)
      duplicate_tasks << duplicate_task
    end

    count_entity_tasks = count_entity_tasks + duplicate_tasks 
  end

  desc "Count all entity types"
  task :all => count_entity_tasks
end
