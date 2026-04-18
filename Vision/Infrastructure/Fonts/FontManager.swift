import UIKit

public struct FontManager {
    public static func registerFonts<T: FontRepresentable>(fontFamily: T.Type) {
        let bundle = Bundle.main

        for font in T.allCases {
            guard let fontURL = bundle.url(forResource: font.rawValue, withExtension: "ttf") else {
                print("⚠️ Cannot find font \(font.rawValue).ttf in bundle")
                continue
            }

            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error) {
                if let err = error?.takeRetainedValue() {
                    let errorDomain = CFErrorGetDomain(err) as String
                    let errorCode = CFErrorGetCode(err)
                    // kCTFontManagerErrorAlreadyRegistered = 105 (for RegisterFontsForURL)
                    // kCTFontManagerErrorAlreadyRegistered = 305 (for RegisterGraphicsFont)
                    if errorDomain == kCTFontManagerErrorDomain as String && (errorCode == 105 || errorCode == 305) {
                        // Already registered, this is fine
                    } else {
                        print("❌ Cannot register font '\(font.rawValue)': \(err.localizedDescription)")
                    }
                }
            } else {
                print("✅ Registered font: \(font.rawValue)")
            }
        }
    }
}

public protocol FontRepresentable: RawRepresentable, CaseIterable where RawValue == String {}

public protocol FontRegisterable: CaseIterable {
    static var allCases: [any StringConvertible] { get }
}

public protocol StringConvertible {
    var stringValue: String { get }
}

extension RawRepresentable where RawValue == String, Self: CaseIterable, Self: FontRegisterable {
    public static var allCases: [any StringConvertible] {
        return allCases.map { $0 as StringConvertible }
    }
}

extension RawRepresentable where RawValue == String, Self: StringConvertible {
    public var stringValue: String {
        return self.rawValue
    }
}
