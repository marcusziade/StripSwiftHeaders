import Foundation

enum FileManagerError: Error { case directoryNotFound }

let directory = "add path here"
let fileManager = FileManager.default

do {
    try processFiles()
} catch {
    print("Error while processing files: \(error)")
}

func processFiles() throws {
    guard let files = try? fileManager.subpathsOfDirectory(atPath: directory) else {
        throw FileManagerError.directoryNotFound
    }
    defer { print("Headers removed from \(directory)") }
    let swiftFiles = files.filter { $0.hasSuffix(".swift") }
    for file in swiftFiles {
        let fileURL = URL(fileURLWithPath: directory, isDirectory: false).appendingPathComponent(file)
        try stripHeaders(fileURL: fileURL)
    }
}

private func stripHeaders(fileURL: URL) throws {
    var inHeader = true
    var lines: [String] = []
    do {
        let fileContent = try String(contentsOf: fileURL)
        lines = fileContent.components(separatedBy: .newlines)
        var newContent = ""
        for line in lines {
            if inHeader && line.hasPrefix("//") && !line.contains("swift-tools-version") {
                continue
            } else if inHeader && !line.hasPrefix("//") {
                if line.isEmpty {
                    continue
                } else {
                    inHeader = false
                }
            }
            newContent += line + "\n"
        }
        try newContent.write(to: fileURL, atomically: true, encoding: .utf8)
    } catch {
        throw error
    }
}
