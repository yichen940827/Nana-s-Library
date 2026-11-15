// Usage: swift tools/flatten-cover.swift <in> <out.png> tlx tly trx try blx bly brx bry
// Corners are in image pixel coordinates (origin top-left). Outputs a flat front-cover PNG.
import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import ImageIO
import UniformTypeIdentifiers

let a = CommandLine.arguments
guard a.count == 11, let ci = CIImage(contentsOf: URL(fileURLWithPath: a[1])) else { print("usage"); exit(1) }
let n = a[3...].map { CGFloat(Double($0)!) }
let H = ci.extent.height
func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: H - y) }
let f = CIFilter.perspectiveCorrection()
f.inputImage = ci
f.topLeft = p(n[0], n[1]); f.topRight = p(n[2], n[3])
f.bottomLeft = p(n[4], n[5]); f.bottomRight = p(n[6], n[7])
let out = f.outputImage!
let ctx = CIContext()
let cg = ctx.createCGImage(out, from: out.extent)!
let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: a[2]) as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, cg, nil)
CGImageDestinationFinalize(dest)
print("ok \(cg.width)x\(cg.height)")
