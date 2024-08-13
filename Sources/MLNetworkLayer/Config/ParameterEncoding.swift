import Foundation

///Parameter encoding types
public enum ParameterEncoding {
    ///Body request with `Json` encoding
    case body

    ///Url request `www-form-urlencoded` with `utf-8` charset
    case url
}
