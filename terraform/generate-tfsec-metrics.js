const fs = require('fs');

console.log("Reading tfsec results...");
const tfsecResults = JSON.parse(fs.readFileSync('tfsec-results.json', 'utf8'));

console.log("Generating Prometheus metrics...");
let metrics = '';

tfsecResults.results.forEach((result, index) => {
    metrics += `# HELP tfsec_vulnerabilities TFsec vulnerability scan results\n`;
    metrics += `# TYPE tfsec_vulnerabilities gauge\n`;
    metrics += `tfsec_vulnerabilities{id="${result.rule_id}",description="${result.description}",severity="${result.severity}",line="${result.location.start_line}"} 1\n`;
});

console.log("Writing metrics to tfsec-metrics.prom...");
fs.writeFileSync('tfsec-metrics.prom', metrics, 'utf8');

console.log("Metrics file tfsec-metrics.prom created successfully.");
