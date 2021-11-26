import Foundation
import ShellOut
import ArgumentParser

struct Run: ParsableCommand {
  static var configuration: CommandConfiguration = .init(
    commandName: "run",
    abstract: "Used by the git-hooks to run your hooks"
  )
  
  @Flag(help: "Produce additional debug logs")
  var verbose: Bool = false
  
  @Flag(help: "Silence all logs")
  var silent: Bool = false
  
  @Argument(help: "Git hook to be executed")
  var hook: String
  
  @Argument(help: "Git params")
  var params: [String]

  func run() throws {
    let logger = Logger(isVerbose: verbose, isSilent: silent)
    let config = try FileConfigSource(logger: logger).config

    if let hookOptions = config[hook] {
        var commands: [String] = []
        if let stringOption = hookOptions as? String {
            commands = [stringOption]
        } else if let arrayOptions = hookOptions as? [String] {
            commands = arrayOptions
        }

        logger.debug("Running commands for komondor \(commands.joined())")
        let stagedFiles = try getStagedFiles(logger)

        do {
            try commands.forEach { command in
                print("[Komondor] > \(hook) \(command)")
                let expandedCommand = expandEdited(forCommand: command, withFiles: stagedFiles)

                // Exporting git hook input params as shell env var GIT_PARAMS
                let cmd = "export GIT_PARAMS=\(params.joined(separator: " ")) ; \(expandedCommand)"
                // Simple is fine for now
                print(try shellOut(to: cmd))
                // Ideal:
                //   Store STDOUT and STDERR, and only show it if it fails
                //   Show a stepper like system of all commands
            }
        } catch let error as ShellOutError {
            print(error.message)
            print(error.output)

            let noVerifyMessage = skippableHooks.contains(hook) ? "add --no-verify to skip" : "cannot be skipped due to Git specs"
            print("[Komondor] > \(hook) hook failed (\(noVerifyMessage))")
          
          throw error
        } catch {
            print(error)
          throw error
        }
    } else {
        logger.logWarning("[Komondor] Could not find a key for '\(hook)' under the komondor settings'")
    }
  }
  
  private func getStagedFiles(_ logger: Logger) throws -> [String] {
      // Find the project root directory
      let projectRootString = try shellOut(to: "git rev-parse --show-toplevel").trimmingCharacters(in: .whitespaces)
      logger.debug("Found project root at: \(projectRootString)")

      let stagedFilesString = try shellOut(to: "git", arguments: ["diff", "--staged", "--diff-filter=ACM", "--name-only"], at: projectRootString)
      logger.debug("Found staged files: \(stagedFilesString)")

      return stagedFilesString == "" ? [] : stagedFilesString.components(separatedBy: "\n")
  }

  private func expandEdited(forCommand command: String, withFiles files: [String]) -> String {
      guard let exts = parseEdited(command: command) else {
          return command
      }

      let matchingFiles = files.filter { file in
          exts.contains(where: { ext in
              file.hasSuffix(".\(ext)")
          })
      }

      return command.replacingOccurrences(of: editedRegexString, with: matchingFiles.joined(separator: " "), options: .regularExpression)
  }
}
