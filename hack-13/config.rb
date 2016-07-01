#local IP address lookup. This hack doesn't make connection to external hosts
require 'socket'
  def local_ip
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

    UDPSocket.open do |s|
      s.connect '8.8.8.8', 1 #google
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = orig
  end

$LOCAL_IP = local_ip

#$SITE_URL = "vm-bioportal-vincent"
$SITE_URL = "lguest-83"


begin
  LinkedData.config do |config|
    config.repository_folder  = "/srv/ncbo/repository"
    config.goo_host           = "localhost"
    config.goo_port           = 8081
    config.search_server_url  = "http://localhost:8082/solr/core1"
    config.rest_url_prefix    = "http://#{$SITE_URL}:8080/"
    config.replace_url_prefix = true
    config.enable_security    = true
    config.apikey             = "24e0e77e-54e0-11e0-9d7b-005056aa3316"
    config.ui_host            = "http://#{$SITE_URL}"
    config.enable_monitoring  = false
    config.cube_host          = "localhost"
    config.enable_slices      = false
    config.enable_resource_index  = false
    config.logger   = Logger.new("/srv/logtest.log")
    config.logger.level = Logger.const_get(ENV['LOG_LEVEL'] ? ENV['LOG_LEVEL'].upcase : 'INFO')

    config.resolve_namespace  = {:skos => "http://www.w3.org/2004/02/skos/core#", :owl => "http://www.w3.org/2002/07/owl#",
                                 :rdfs => "http://www.w3.org/2000/01/rdf-schema#", :omv => "http://omv.ontoware.org/2005/05/ontology#",
                                 :foaf => "http://xmlns.com/foaf/0.1/", :void => "http://rdfs.org/ns/void#",
                                 :cc => "http://creativecommons.org/ns#", :dcat => "http://www.w3.org/ns/dcat#",
                                 :schema => "http://schema.org/", :prov => "http://www.w3.org/ns/prov#",
                                 :adms => "http://www.w3.org/ns/adms#", :dct => "http://purl.org/dc/terms/"}

    config.interportal_hash   = {"ncbo" => {"api" => "http://data.bioontology.org", "ui" => "http://bioportal.bioontology.org", "apikey" => "4a5011ea-75fa-4be6-8e89-f45c8c84844e"},
                                 "agro" => {"api" => "http://data.agroportal.lirmm.fr", "ui" => "http://agroportal.lirmm.fr", "apikey" => "1cfae05f-9e67-486f-820b-b393dec5764b"}}

    # Caches
    config.http_redis_host    = "localhost"
    config.http_redis_port    = 6380
    config.enable_http_cache  = true
    config.goo_redis_host     = "localhost"
    config.goo_redis_port     = 6382

    Goo.use_cache             = true

    # Email notifications
    config.enable_notifications   = false
    config.email_sender           = "root@vm-bioportal-vincent" # Default sender for emails
    config.email_override         = "override@example.org" # all email gets sent here. Disable with email_override_disable.
    config.email_disable_override = true
    config.smtp_host              = "localhost"
    config.smtp_port              = 25
    config.smtp_auth_type         = :none # :none, :plain, :login, :cram_md5
    config.smtp_domain            = "lirmm.fr"

    # PURL server config parameters
    config.enable_purl            = false
    config.purl_host              = "purl.example.org"
    config.purl_port              = 80
    config.purl_username          = "admin"
    config.purl_password          = "password"
    config.purl_maintainers       = "admin"
    config.purl_target_url_prefix = "http://example.org"

    # Ontology Google Analytics Redis
    # disabled
    config.ontology_analytics_redis_host = "localhost"
    config.enable_ontology_analytics = false
    config.ontology_analytics_redis_port = 6379
end
rescue NameError
  puts "(CNFG) >> LinkedData not available, cannot load config"
end

begin
  Annotator.config do |config|
    config.mgrep_dictionary_file   = "/srv/mgrep/dictionary/dictionary.txt"
    config.stop_words_default_file = "./config/default_stop_words.txt"
    config.mgrep_host              = "localhost"
    config.mgrep_port              = 55555
    config.mgrep_alt_host          = "localhost"
    config.mgrep_alt_port          = 55555
    config.annotator_redis_host    = "localhost"
    config.annotator_redis_port    = 6379
    config.annotator_redis_prefix  = ""
    config.annotator_redis_alt_prefix  = "c2"
    config.enable_recognizer_param = true
    # in alvis dir: bin/alvisnlp and alvis-annotator/alvis-annotator.plan"
    config.alvis_recognizer_path = "/srv/alvisnlp"
    # in treetagger dir: english-par-linux-3.2.bin and bin/tree-tagger
    config.tree_tagger_path = "/srv/treetagger"
end
rescue NameError
  puts "(CNFG) >> Annotator not available, cannot load config"
end

begin
  OntologyRecommender.config do |config|
end
rescue NameError
  puts "(CNFG) >> OntologyRecommender not available, cannot load config"
end

begin
  LinkedData::OntologiesAPI.config do |config|
    config.enable_unicorn_workerkiller = true
    config.enable_throttling           = false
    config.enable_monitoring           = false
    config.cube_host                   = "localhost"
    config.http_redis_host             = "localhost"
    config.http_redis_port             = 6380
    config.ontology_rank               = ""
end
rescue NameError
	  puts "(CNFG) >> OntologiesAPI not available, cannot load config"
end

begin
  NcboCron.config do |config|
    config.redis_host                = Annotator.settings.annotator_redis_host
    config.redis_port                = Annotator.settings.annotator_redis_port
    
    # Schedules: run every 4 hours, starting at 00:30
    config.cron_schedule                                = "30 */4 * * *"
    # Pull schedule: run daily at 6 a.m. (18:00)
    config.pull_schedule                                = "00 18 * * *"
    # Delete class graphs of archive submissions: run twice per week on tuesday and friday at 10 a.m. (22:00)
    config.cron_flush                                   = "00 22 * * 2,5"
    # Warmup long time running queries: run every 3 hours (beginning at 00:00)
    config.cron_warmq                                   = "00 */3 * * *"
    # Create mapping counts schedule: run twice per week on Wednesday and Saturday at 12:30AM
    config.cron_mapping_counts                          = "30 0 * * 3,6"
    
    config.enable_ontologies_report  = true
    # Ontologies report generation schedule: run daily at 1:30 a.m.
    config.cron_ontologies_report                       = "30 1 * * *"
    # Ontologies Report file location
    config.ontology_report_path = "/srv/ncbo/reports/ontologies_report.json"
    
	# Ontology analytics refresh schedule: run daily at 4:30 a.m.
    config.cron_ontology_analytics                      = "30 4 * * *"
    config.enable_ontology_analytics = false
    #config.analytics_service_account_email_address  = "account-1@agroportal-1131.iam.gserviceaccount.com"
    #config.analytics_path_to_key_file               = "/srv/ncbo/ontologies_api/current/config/agroportal-ff92c5b03a79.p12" # you have to get this file from Google
    #config.analytics_profile_id                     = "ga:111823457" # replace with your ga view id
    #config.analytics_app_name                       = "agroportal"
    #config.analytics_app_version                    = "1.0.0"
    #config.analytics_start_date                     = "2015-11-16"
    #config.analytics_filter_str                     = ""
  end
rescue NameError
  #binding.pry
  puts "(CNFG) >> NcboCron not available, cannot load config"
end

