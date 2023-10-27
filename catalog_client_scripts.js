function onSubmit() {
   var subnets = JSON.parse(g_form.getValue("subnets"));
   g_form.setValue('GCP_Network_subnets',JSON.stringify(subnets));
}

function onSubmit() {
   var compute_instances = JSON.parse(g_form.getValue("compute_instances"));
   for (i = 0; i < compute_instances.length; i++) {
    compute_instances[i].compute_tags = JSON.parse("[" + JSON.stringify(compute_instances[i].compute_tags) + "]");
   }
	
   g_form.setValue('GCP_Network_compute_instances',JSON.stringify(compute_instances));
}

function onSubmit() {
   var fw_rules = JSON.parse(g_form.getValue("firewall_rules"));
   for (i = 0; i < fw_rules.length; i++) {
    fw_rules[i].fw_destination_ranges = JSON.parse("[" + JSON.stringify(fw_rules[i].fw_destination_ranges) + "]");
	fw_rules[i].fw_source_ranges = JSON.parse("[" + JSON.stringify(fw_rules[i].fw_source_ranges) + "]");
	fw_rules[i].fw_source_tags = JSON.parse("[" + JSON.stringify(fw_rules[i].fw_source_tags) + "]");
	fw_rules[i].fw_target_tags = JSON.parse("[" + JSON.stringify(fw_rules[i].fw_target_tags) + "]");
	fw_rules[i].allow = "{ protocol: " + fw_rules[i].allow.split(":")[0] + ", ports: " + fw_rules[i].allow.split(":")[1] + "}";
	fw_rules[i].deny = "{ protocol: " + fw_rules[i].deny.split(":")[0] + ", ports: " + fw_rules[i].deny.split(":")[1] + "}";
   }
	
   g_form.setValue('GCP_Network_firewall_rules',JSON.stringify(fw_rules));
}

function onSubmit() {
    var routes = JSON.parse(g_form.getValue("routes"));
     
    g_form.setValue('GCP_Network_routes',JSON.stringify(routes));
 }