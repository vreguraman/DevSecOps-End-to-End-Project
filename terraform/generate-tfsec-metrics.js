const fs = require('fs');

console.log("Reading TFsec results...");
const tfsecResults = JSON.parse(fs.readFileSync('tfsec-results.json', 'utf8'));

console.log("Generating Prometheus metrics...");
let metrics = "# HELP tfsec_vulnerabilities TFsec vulnerability scan results\n";
metrics += "# TYPE tfsec_vulnerabilities gauge\n";

tfsecResults.results.forEach(result => {
    metrics += `tfsec_vulnerabilities{severity="${result.severity}",rule_id="${result.rule_id}",description="${result.description.replace(/"/g, '\\"')}"} 1\n`;
});

console.log("Writing metrics to tfsec-metrics.prom...");
fs.writeFileSync('tfsec-metrics.prom', metrics);

console.log("Metrics file tfsec-metrics.prom created successfully.")
