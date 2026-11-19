import SwiftUI

extension Animation {
    static let appFast = Animation.easeInOut(duration: 0.15)
    static let appStandard = Animation.easeInOut(duration: 0.25)
    static let appSpring = Animation.spring(duration: 0.3)
    static let appSlow = Animation.easeOut(duration: 0.6)
}
