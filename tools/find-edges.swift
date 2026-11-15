// Usage: swift tools/find-edges.swift <image> [row]
// Prints non-white extents per sampled row and column, plus color along a middle row.
import Foundation
import CoreGraphics
import ImageIO

let url = URL(fileURLWithPath: CommandLine.arguments[1])
let src = CGImageSourceCreateWithURL(url as CFURL, nil)!
let img = CGImageSourceCreateImageAtIndex(src, 0, nil)!
let w = img.width, h = img.height
var data = [UInt8](repeating: 0, count: w * h * 4)
let ctx = CGContext(data: &data, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                    space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
func px(_ x: Int, _ y: Int) -> (Int, Int, Int) { let i = (y * w + x) * 4; return (Int(data[i]), Int(data[i+1]), Int(data[i+2])) }
func white(_ p: (Int, Int, Int)) -> Bool { p.0 > 240 && p.1 > 240 && p.2 > 240 }
for y in stride(from: 0, to: h, by: 50) {
  var l = -1, r = -1
  for x in 0..<w where !white(px(x, y)) { if l < 0 { l = x }; r = x }
  print("row \(y): \(l)...\(r)")
}
for x in stride(from: 0, to: w, by: 40) {
  var t = -1, b = -1
  for y in 0..<h where !white(px(x, y)) { if t < 0 { t = y }; b = y }
  print("col \(x): \(t)...\(b)")
}
let y = Int(CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "300")!
for x in stride(from: 500, to: w, by: 4) { print("x\(x) \(px(x, y))") }
