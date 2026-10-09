import AppKit

let output = URL(fileURLWithPath: CommandLine.arguments[1])
let image = NSImage(size: NSSize(width: 1024, height: 1024))
image.lockFocus()
NSColor(srgbRed: 0.89, green: 0.92, blue: 0.86, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 32, y: 32, width: 960, height: 960),
             xRadius: 210, yRadius: 210).fill()
NSGraphicsContext.saveGraphicsState()
let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.22)
shadow.shadowBlurRadius = 40
shadow.shadowOffset = NSSize(width: 0, height: -22)
shadow.set()
NSColor.white.setFill()
NSBezierPath(roundedRect: NSRect(x: 175, y: 150, width: 674, height: 712),
             xRadius: 65, yRadius: 65).fill()
NSGraphicsContext.restoreGraphicsState()
NSColor(srgbRed: 0.91, green: 0.94, blue: 0.80, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 214, y: 194, width: 596, height: 510),
             xRadius: 40, yRadius: 40).fill()
let ink = NSColor(srgbRed: 0.40, green: 0.51, blue: 0.27, alpha: 1)
ink.withAlphaComponent(0.35).setFill()
for (row, width) in [380.0, 440, 310].enumerated() {
    NSBezierPath(roundedRect: NSRect(x: 278, y: 580 - Double(row) * 98,
                                    width: width, height: 20), xRadius: 10, yRadius: 10).fill()
}
ink.setFill()
NSBezierPath(ovalIn: NSRect(x: 454, y: 724, width: 116, height: 72)).fill()
let pin = NSBezierPath(ovalIn: NSRect(x: 466, y: 748, width: 92, height: 92))
NSGradient(starting: NSColor(srgbRed: 0.67, green: 0.74, blue: 0.45, alpha: 1),
           ending: ink)!.draw(in: pin, angle: -90)
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
