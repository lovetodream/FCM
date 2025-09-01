import HTTPTypes
import NIOHTTP1

extension HTTPFields {
    func getParameter(_ name: HTTPFields.Element.Name, _ key: String) -> String? {
        headerParts(name: name)?
            .filter { $0.starts(with: "\(key)=") }
            .first?
            .split(separator: "=")
            .last?
            .trimmingCharacters(in: .init(charactersIn: #""'"#))
    }

    func headerParts(name: HTTPFields.Element.Name) -> [String]? {
        self[name]
            .flatMap {
                $0.split(separator: ";")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
            }
    }
}

extension HTTPHeaders {
    func getParameter(_ name: String, _ key: String) -> String? {
        headerParts(name: name)?
            .filter { $0.starts(with: "\(key)=") }
            .first?
            .split(separator: "=")
            .last?
            .trimmingCharacters(in: .init(charactersIn: #""'"#))
    }

    func headerParts(name: String) -> [String]? {
        self[name]
            .flatMap {
                $0.split(separator: ";")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
            }
    }
}
