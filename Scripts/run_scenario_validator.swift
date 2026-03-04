import Foundation

@main
struct ScenarioValidationRunner {
    static func main() {
        let args = CommandLine.arguments.dropFirst()
        let scenarioRootPath = args.first ?? defaultScenarioRootPath()
        let rootURL = URL(fileURLWithPath: scenarioRootPath, isDirectory: true)

        let reports = ScenarioValidator().validateAllScenarios(at: rootURL)
        if reports.isEmpty {
            fputs("No scenarios found at \(rootURL.path)\n", stderr)
            exit(1)
        }

        var errorCount = 0
        var warningCount = 0

        for report in reports where !report.issues.isEmpty {
            print(report.formattedDescription)
            print("---")
            errorCount += report.errors.count
            warningCount += report.warnings.count
        }

        print("Validation complete: \(reports.count) scenario(s), \(errorCount) error(s), \(warningCount) warning(s).")
        exit(errorCount == 0 ? 0 : 1)
    }

    private static func defaultScenarioRootPath() -> String {
        let scriptURL = URL(fileURLWithPath: #filePath)
        return scriptURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Content/Scenarios", isDirectory: true)
            .path
    }
}
