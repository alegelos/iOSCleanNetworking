import Foundation

/// Reads local JSON files from a given bundle.
public enum JSONReader: Sendable {

    /// Loads a JSON file from the provided bundle.
    ///
    /// - Parameters:
    ///   - fileName: The name of the JSON file, without the `.json` extension.
    ///   - bundle: The bundle where the JSON file is located.
    ///
    /// - Returns: The contents of the JSON file as `Data`.
    ///
    /// - Throws:
    ///   - `Errors.nilFileName` if `fileName` is `nil`.
    ///   - `Errors.fileNameNotFound` if the file cannot be found in the provided bundle.
    ///   - Any error thrown by `Data(contentsOf:)` while reading the file contents.
    public static func localJSON(_ fileName: String?, in bundle: Bundle = .main) throws -> Data {
        guard let fileName else {
            throw Errors.nilFileName
        }

        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw Errors.fileNameNotFound
        }

        return try Data(contentsOf: url)
    }
}

public extension JSONReader {

    /// Errors thrown by `JSONReader`.
    enum Errors: Error {

        /// Indicates that the JSON file could not be found in the provided bundle.
        case fileNameNotFound

        /// Indicates that the provided file name was `nil`.
        case nilFileName
    }
}
