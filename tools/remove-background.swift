// Usage: swift tools/remove-background.swift <input image> <output.png>
// Removes the background using macOS Vision foreground masking (macOS 14+).
import Foundation
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import ImageIO
import UniformTypeIdentifiers

let args = CommandLine.arguments
guard args.count == 3 else { print("usage: removebg <in> <out.png>"); exit(1) }
let inURL = URL(fileURLWithPath: args[1]), outURL = URL(fileURLWithPath: args[2])
guard let ci = CIImage(contentsOf: inURL) else { print("cannot read input"); exit(1) }

let handler = VNImageRequestHandler(ciImage: ci)
let req = VNGenerateForegroundInstanceMaskRequest()
try handler.perform([req])
guard let obs = req.results?.first else { print("no foreground found"); exit(2) }
let maskBuf = try obs.generateScaledMaskForImage(forInstances: obs.allInstances, from: handler)
let mask = CIImage(cvPixelBuffer: maskBuf)

let blend = CIFilter.blendWithMask()
blend.inputImage = ci
blend.backgroundImage = CIImage.empty()
blend.maskImage = mask
guard let out = blend.outputImage else { exit(3) }

let ctx = CIContext()
guard let cg = ctx.createCGImage(out, from: ci.extent) else { exit(4) }
guard let dest = CGImageDestinationCreateWithURL(outURL as CFURL, UTType.png.identifier as CFString, 1, nil) else { exit(5) }
CGImageDestinationAddImage(dest, cg, nil)
CGImageDestinationFinalize(dest)
print("ok \(cg.width)x\(cg.height)")
