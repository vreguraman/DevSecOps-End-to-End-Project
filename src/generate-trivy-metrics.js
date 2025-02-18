const fs = require('fs');

try {
    console.log('Reading Trivy results...');
    const trivyResults = JSON.parse(fs.readFileSync('trivy-results.json', 'utf8'));

    console.log('Generating Prometheus metrics...');
    const metrics = [];
    trivyResults.Results.forEach((result) => {
        result.Vulnerabilities.forEach((vuln) => {
            metrics.push(`# HELP trivy_vulnerabilities Trivy vulnerability scan results`);
            metrics.push(`# TYPE trivy_vulnerabilities gauge`);
            metrics.push(`trivy_vulnerabilities{image="${result.Target}",severity="${vuln.Severity}",id="${vuln.VulnerabilityID}"} 1`);
        });
    });

    console.log('Writing metrics to trivy-metrics.prom...');
    fs.writeFileSync('trivy-metrics.prom', metrics.join('\n'));
    console.log('Metrics file trivy-metrics.prom created successfully.');
} catch (error) {
    console.error('Error:', error.message);
}
