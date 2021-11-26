import Foundation
import ArgumentParser

/// Version for showing in verbose mode
public let KomondorVersion = "1.0.0"

public struct Komondor: ParsableCommand {
  public static let configuration = CommandConfiguration(
    abstract: """
    Welcome to Komondor. Docs are available at: https://github.com/shibapm/Komondor
    """,
    version: KomondorVersion,
    subcommands: [Install.self, Uninstall.self, Run.self]
  )
  
  public init() { }
}

Komondor.main()
