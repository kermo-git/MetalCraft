import SwiftUI
import UIKit
import CoreImage

// https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage
func getAverageColor(
    context: CIContext = CIContext(options: [.workingColorSpace: kCFNull!]),
    textureName: String) -> Color {
    
    guard let url = Bundle.main.url(forResource: textureName,
                                    withExtension: "png") else {
        return .black
    }
    
    guard let image = CIImage(contentsOf: url) else {
        return .black
    }
    
    let extent = CIVector(
        x: image.extent.origin.x,
        y: image.extent.origin.y,
        z: image.extent.size.width,
        w: image.extent.size.height
    )
    
    guard let filter = CIFilter(
        name: "CIAreaAverage",
        parameters: [
            kCIInputImageKey: image,
            kCIInputExtentKey: extent
        ]
    ) else {
        return .black
    }

    guard let outputImage = filter.outputImage else { return .black }
    var bitmap = [UInt8](repeating: 0, count: 4)

    context.render(
        outputImage,
        toBitmap: &bitmap,
        rowBytes: 4,
        bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
        format: .RGBA8,
        colorSpace: nil
    )
    
    return Color(red: Double(bitmap[0]) / 255.0,
                 green: Double(bitmap[1]) / 255.0,
                 blue: Double(bitmap[2]) / 255.0)
}

func getAverageColors(textureNames: [String]) -> [Color] {
    let context = CIContext(options: [.workingColorSpace: kCFNull!])
    return textureNames.map {
        textureName in getAverageColor(
            context: context,
            textureName: textureName
        )
    }
}

struct Pixel: Identifiable {
    var color: Color
    let id: String
}

struct PixelRow: Identifiable {
    var pixels: [Pixel]
    let id: String
}

typealias PixelGrid = [PixelRow]

extension PixelGrid {
    func rows() -> Int { self.count }
    func columns() -> Int { self[0].pixels.count }
    
    subscript(row: Int, column: Int) -> Color {
        get {
            return self[row].pixels[column].color
        } set(newValue) {
            self[row].pixels[column].color = newValue
        }
    }
}

func createPixelGrid(rows: Int, columns: Int) -> PixelGrid {
    var result: PixelGrid = []
    
    for i in 0..<rows {
        var pixels: [Pixel] = []
        
        for j in 0..<columns {
            pixels.append(
                Pixel(color: .black,
                      id: "pixel_\(i)_\(j)")
            )
        }
        result.append(
            PixelRow(pixels: pixels, id: "row_\(i)")
        )
    }
    return result
}

func getChunk2DMap(chunk: Chunk, blockColors: [Color]) -> [PixelRow] {
    var map = createPixelGrid(
        rows: chunk.lengthZ,
        columns: chunk.lengthX
    )
    
    for X in 0..<chunk.lengthX {
        for Z in 0..<chunk.lengthZ {
            for Y in chunk.maxY...0 {
                
            }
        }
    }
    return map
}

struct PixelArt: View {
    let image: PixelGrid
    
    var body: some View {
        GeometryReader { geometry in
            let pixelSide = geometry.size.width / CGFloat(image.columns())
            
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(image) { row in GridRow {
                    ForEach(row.pixels) {
                        pixel in pixel.color.frame(
                            width: pixelSide, height: pixelSide
                        )
                    }
                }}
            }
        }
    }
}

func toPixelGrid(_ image: [[Color]]) -> PixelGrid {
    var result = createPixelGrid(
        rows: image.count,
        columns: image[0].count
    )
    
    for i in 0..<image.count {
        for j in 0..<image[0].count {
            result[i, j] = image[i][j]
        }
    }
    return result
}

#Preview(traits: .landscapeRight) {
    PixelArt(image: toPixelGrid([
        [.blue, .orange, .pink, .green, .purple, .yellow],
        [.green, .purple, .yellow, .blue, .orange, .pink],
        [.blue, .orange, .pink, .green, .purple, .yellow]
    ])).edgesIgnoringSafeArea(.all)
}
