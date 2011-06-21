#!/usr/bin/ruby -w

def run_query(query_file, type='N-TRIPLES')
  system("bash", "-c", "cd /usr/share/vivo/harvester; source /usr/share/vivo/harvester/scripts/env; $JenaConnect -j $VIVOCONFIG -JcheckEmpty=$CHECKEMPTY -Q #{type} -q \"`cat #{query_file}`\" > #{query_file}.nt")
end

query_files = [ "~/dev/remove_data/tag_entity_constructs/RoleQuery.sparql",
  "~/dev/remove_data/tag_entity_constructs/DateTimeInterval.sparql",
  "~/dev/remove_data/tag_entity_constructs/CoPIStubQuery.sparql",
  "~/dev/remove_data/tag_entity_constructs/PIStubQuery.sparql",
  "~/dev/remove_data/tag_entity_constructs/OrganizationAdminister.sparql",
  "~/dev/remove_data/tag_entity_constructs/OrganizationAward.sparql",
  "~/dev/remove_data/tag_entity_constructs/OrganizationSubContracted.sparql",
  "~/dev/remove_data/tag_entity_constructs/GrantQuery.sparql",
]

query_files.each do |query_file|
  puts "Start query: #{query_file}"
  system("date")
  run_query(query_file)
  system("cat #{query_file}.nt | wc -l")
  puts "End query"
end
