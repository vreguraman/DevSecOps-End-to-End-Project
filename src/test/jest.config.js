module.exports = {
  testEnvironment: 'node',
  collectCoverage: false, // Disables code coverage report
  coverageDirectory: "./coverage", // Specifies output directory for coverage reports
  coverageReporters: ["json", "lcov", "text", "clover"], // Generates multiple coverage formats
  testPathIgnorePatterns: ["/node_modules/", "/dist/"], // Exclude unnecessary folders
  reporters: [
    "default",
    ["jest-junit", { outputDirectory: "./test-results", outputName: "results.xml" }]
  ],
  verbose: true, // Enables detailed test execution logs
};