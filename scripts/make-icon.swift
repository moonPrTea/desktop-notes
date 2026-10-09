import AppKit

let output = URL(fileURLWithPath: CommandLine.arguments[1])
let image = NSImage(size: NSSize(width: 1024, height: 1024))
image.lockFocus()
NSColor(calibratedWhite: 0.94, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 32, y: 32, width: 960, height: 960),
             xRadius: 210, yRadius: 210).fill()
NSGraphicsContext.saveGraphicsState()
let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.12)
shadow.shadowBlurRadius = 40
shadow.shadowOffset = NSSize(width: 0, height: -22)
shadow.set()
NSColor.white.setFill()
NSBezierPath(roundedRect: NSRect(x: 175, y: 150, width: 674, height: 712),
             xRadius: 65, yRadius: 65).fill()
NSGraphicsContext.restoreGraphicsState()
NSColor(calibratedWhite: 0.88, alpha: 1).setStroke()
let border = NSBezierPath(roundedRect: NSRect(x: 175, y: 150, width: 674, height: 712),
                          xRadius: 65, yRadius: 65)
border.lineWidth = 3
border.stroke()
for (row, width) in [320.0, 440, 380, 260].enumerated() {
    NSColor(calibratedWhite: row == 0 ? 0.20 : 0.72, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: 266, y: 686 - Double(row) * 100,
                                    width: width, height: row == 0 ? 30 : 18),
                 xRadius: 9, yRadius: 9).fill()
}
image.unlockFocus()
let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
let png = bitmap.representation(using: .png, properties: [:])!
// ic10 embeds a 1024px PNG; Finder derives smaller sizes from it.
var data = Data("icns".utf8)
func appendLength(_ value: Int) {
    var number = UInt32(value).bigEndian
    withUnsafeBytes(of: &number) { data.append(contentsOf: $0) }
}
appendLength(png.count + 16)
data.append(Data("ic10".utf8))
appendLength(png.count + 8)
data.append(png)
try data.write(to: output)
