import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #EFEDE7
    static let bg = Color(red: 0.937255, green: 0.929412, blue: 0.905882)
    static let bgHex = "#EFEDE7"
    /// #F5F6F3
    static let surface = Color(red: 0.960784, green: 0.964706, blue: 0.952941)
    static let surfaceHex = "#F5F6F3"
    /// #2A2614
    static let ink = Color(red: 0.164706, green: 0.149020, blue: 0.078431)
    static let inkHex = "#2A2614"
    /// #668B0E
    static let accent = Color(red: 0.400000, green: 0.545098, blue: 0.054902)
    static let accentHex = "#668B0E"
    /// #686246
    static let muted = Color(red: 0.407843, green: 0.384314, blue: 0.274510)
    static let mutedHex = "#686246"
    static let fontFamily = "DIN Condensed"
}
