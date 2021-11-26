import Foundation
import ShellOut
import ArgumentParser

struct Uninstall: ParsableCommand {
  static var configuration: CommandConfiguration = .init(
    commandName: "uninstall",
    abstract: "Removes git-hooks created by Komondor"
  )
  
  @Flag(help: "Produce additional debug logs")
  var verbose: Bool = false
  
  @Flag(help: "Silence all logs")
  var silent: Bool = false
  
  func run() throws {
    let logger = Logger(isVerbose: verbose, isSilent: silent)
    
    // Validate we're in a git repo
    do {
        try shellOut(to: "git remote")
    } catch {
        logger.logError("[Komondor] Can only uninstall git-hooks into a git repo.")
        return
    }

    let fileManager = FileManager.default

    // Find the .git root
    let gitRootString = try shellOut(to: "git rev-parse --git-dir").trimmingCharacters(in: .whitespaces)
    logger.debug("Found git root at: \(gitRootString)")

    // Find or create the hooks dir in the .git folder
    var hooksRoot = URL(fileURLWithPath: gitRootString)
    hooksRoot.appendPathComponent("hooks", isDirectory: true)

    // If no hooks dir just exit
    guard fileManager.fileExists(atPath: hooksRoot.path) else {
        print("[Komondor] hooks directory does not exist, no hooks to uninstall")
      return
    }

    try hookList.forEach { hookName in
        var hookPath = URL(fileURLWithPath: hooksRoot.absoluteString)
        hookPath.appendPathComponent(hookName)

        guard fileManager.fileExists(atPath: hookPath.path) else {
            logger.debug("Skipped non-existant hook: \(hookName)")
            return
        }

        let fileData = try Data(contentsOf: hookPath, options: [])
        let content = String(data: fileData, encoding: .utf8)!

        // Only remove hook if it was created by Komondor
        guard content.contains("# Komondor") else {
            logger.debug("Skipped non-Komondor hook: \(hookName)")
            return
        }

        logger.debug("Removing the hook: \(hookName)")
        try fileManager.removeItem(atPath: hookPath.path)
    }

    print("[Komondor] git-hooks uninstalled")
  }
}
