import Foundation

public protocol URLSessionSetupProtocol {

    var jsonFileName: String { get }
    var jsonBundle: Bundle { get }

}

public extension URLSessionSetupProtocol {
    var jsonBundle: Bundle { .main }
}
