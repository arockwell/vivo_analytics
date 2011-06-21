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

query_files = { :role => "~/dev/remove_data/tag_entity_constructs/RoleQuery.sparql",
  :date_time_interval => "~/dev/remove_data/tag_entity_constructs/DateTimeInterval.sparql",
  :co_pi_stub => "~/dev/remove_data/tag_entity_constructs/CoPIStubQuery.sparql",
  :pi_stub => "~/dev/remove_data/tag_entity_constructs/PIStubQuery.sparql",
  :organization_administer => "~/dev/remove_data/tag_entity_constructs/OrganizationAdminister.sparql",
  :organization_award => "~/dev/remove_data/tag_entity_constructs/OrganizationAward.sparql",
  :organization_sub_contracted => "~/dev/remove_data/tag_entity_constructs/OrganizationSubContracted.sparql",
  :grant_query => "~/dev/remove_data/tag_entity_constructs/GrantQuery.sparql",
}

task :query_non_uf_orgs do
  run_query(query_files[:organization_award])
  run_query(query_files[:organization_sub_contracted])
end

task :remove_non_uf_orgs do
  remove_file("#{query_files[:organization_award]}.nt")
  remove_file("#{query_files[:organization_sub_contracted]}.nt")
end

task :query_all_entities do
  query_files.each do |name, file|
    puts "Running #{file}"
    system("date")
    run_query(file)
  end
end
