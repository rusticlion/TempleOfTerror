import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
extension ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
extension ImageResource {

    /// The "icon_bonus_action" asset catalog image resource.
    static let iconBonusAction = ImageResource(name: "icon_bonus_action", bundle: resourceBundle)

    /// The "icon_harm_lesser_empty" asset catalog image resource.
    static let iconHarmLesserEmpty = ImageResource(name: "icon_harm_lesser_empty", bundle: resourceBundle)

    /// The "icon_harm_lesser_full" asset catalog image resource.
    static let iconHarmLesserFull = ImageResource(name: "icon_harm_lesser_full", bundle: resourceBundle)

    /// The "icon_harm_moderate_empty" asset catalog image resource.
    static let iconHarmModerateEmpty = ImageResource(name: "icon_harm_moderate_empty", bundle: resourceBundle)

    /// The "icon_harm_moderate_full" asset catalog image resource.
    static let iconHarmModerateFull = ImageResource(name: "icon_harm_moderate_full", bundle: resourceBundle)

    /// The "icon_harm_severe_empty" asset catalog image resource.
    static let iconHarmSevereEmpty = ImageResource(name: "icon_harm_severe_empty", bundle: resourceBundle)

    /// The "icon_harm_severe_full" asset catalog image resource.
    static let iconHarmSevereFull = ImageResource(name: "icon_harm_severe_full", bundle: resourceBundle)

    /// The "icon_penalty_action" asset catalog image resource.
    static let iconPenaltyAction = ImageResource(name: "icon_penalty_action", bundle: resourceBundle)

    /// The "icon_stress_pip_lit" asset catalog image resource.
    static let iconStressPipLit = ImageResource(name: "icon_stress_pip_lit", bundle: resourceBundle)

    /// The "icon_stress_pip_unlit" asset catalog image resource.
    static let iconStressPipUnlit = ImageResource(name: "icon_stress_pip_unlit", bundle: resourceBundle)

    /// The "texture_dicetray_surface" asset catalog image resource.
    static let textureDicetraySurface = ImageResource(name: "texture_dicetray_surface", bundle: resourceBundle)

    /// The "texture_stone_door" asset catalog image resource.
    static let textureStoneDoor = ImageResource(name: "texture_stone_door", bundle: resourceBundle)

    /// The "vfx_damage_vignette" asset catalog image resource.
    static let vfxDamageVignette = ImageResource(name: "vfx_damage_vignette", bundle: resourceBundle)

}

// MARK: - Backwards Deployment Support -

/// A color resource.
struct ColorResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog color resource name.
    fileprivate let name: Swift.String

    /// An asset catalog color resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize a `ColorResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

/// An image resource.
struct ImageResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog image resource name.
    fileprivate let name: Swift.String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize an `ImageResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// Initialize a `NSColor` with a color resource.
    convenience init(resource: ColorResource) {
        self.init(named: NSColor.Name(resource.name), bundle: resource.bundle)!
    }

}

protocol _ACResourceInitProtocol {}
extension AppKit.NSImage: _ACResourceInitProtocol {}

@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension _ACResourceInitProtocol {

    /// Initialize a `NSImage` with an image resource.
    init(resource: ImageResource) {
        self = resource.bundle.image(forResource: NSImage.Name(resource.name))! as! Self
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// Initialize a `UIColor` with a color resource.
    convenience init(resource: ColorResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}

@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// Initialize a `UIImage` with an image resource.
    convenience init(resource: ImageResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    init(_ resource: ColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Image {

    /// Initialize an `Image` with an image resource.
    init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif