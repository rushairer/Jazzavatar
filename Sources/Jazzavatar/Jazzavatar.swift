import SwiftUI
import UIColorHexSwift
import CryptoKit

public struct Jazzavatar {
    public struct Segment: Hashable {
        let color: String
        let offsetX: Double
        let offsetY: Double
        let rotate: Double
    }
    
    public private(set) var segments: [Segment] = []
    public private(set) var backgroundColorName: String = ""

    private var colorNames: [String] = [
        "#01888C", // teal
        "#FC7500", // bright orange
        "#034F5D", // dark teal
        "#F73F01", // orangered
        "#FC1960", // magenta
        "#C7144C", // raspberry
        "#F3C100", // goldenrod
        "#1598F2", // lightning blue
        "#2465E1", // sail blue
        "#F19E02", // gold
    ]
    
    private var mersenne: MersenneTwister
    private var name: String

    private let shapeCount = 4
    
    public init(name: String) {
        self.name = name
        self.mersenne = MersenneTwister(seed: UInt32(truncating: name.toNumber() as NSNumber))
        self.colorNames = colorNamesHueShift()
        
        let (backgroundColorName, newNames) = genColor(colorNames: self.colorNames)
        self.backgroundColorName = backgroundColorName
        
        var tempNames = newNames
        
        var segments: [Segment] = []
        
        for i in 0..<(shapeCount-1) {
            let (segment, newColorNames) = genSegment(colorNames: tempNames, index: i)
            tempNames = newColorNames
            segments.append(segment)
        }
        
        self.segments = segments
    }
    
    private mutating func colorNamesHueShift() -> [String] {
        let amount = mersenne.nextReal2() * Double(30) - Double(15)
        return colorNames.map { colorName in
            
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            
#if canImport(UIKit)
            let color = UIColor(colorName)
            color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            hue = (360.0 * hue + amount) / 360.0
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1).hexString(false)
#elseif canImport(AppKit)
            let color = NSColor(colorName)
            color?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            hue = (360.0 * hue + amount) / 360.0
            return NSColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1).hexString(false)
#endif
        }
    }
    
    private mutating func genColor(colorNames: [String]) -> (String, [String]) {
        _ = mersenne.nextReal2()
        let index = Int(truncating: floor(Double(colorNames.count) * mersenne.nextReal2()) as NSNumber)
        
        let bg = Array(colorNames[index...])[0]
        var colors = colorNames[..<index]
        colors.append(contentsOf: colorNames[(index+1)...])
        return (bg, Array(colors))
    }
    
    private mutating func genSegment(colorNames: [String], index: Int) -> (Segment, [String]) {
        let rand1 = mersenne.nextReal2()
        let angle = Double.pi * 2.0 * rand1
        let total = shapeCount-1
        let velocity = (mersenne.nextReal2() + Double(index)) / Double(total)
        
        let offsetX = cos(angle) * velocity
        let offsetY = sin(angle) * velocity
        
        let rand2 = mersenne.nextReal2()
        
        let rotate = round((rand1 * 360.0 + rand2 * 180.0) * 10.0) / 10.0
        
        let (color, newColorNames) = genColor(colorNames: colorNames)
        
        let segment = Segment(
            color: color,
            offsetX: offsetX,
            offsetY: offsetY,
            rotate: rotate
        )

        return (segment, newColorNames)
    }
    
}

extension String {
    func hexToUInt64() -> UInt64? {
        let newString = self[self.startIndex..<self.index(self.startIndex, offsetBy: min(8, count))]
        return UInt64(newString, radix: 16)
    }
    
    func toNumber() -> UInt64 {
        if let number = self.replacingOccurrences(of: "0x", with: "").hexToUInt64() {
            return number
        } else {
            return self.insecureMD5Hash()?.hexToUInt64() ?? 0
        }
    }
}

private protocol ByteCountable {
    static var byteCount: Int { get }
}

extension Insecure.MD5: ByteCountable { }
extension Insecure.SHA1: ByteCountable { }

extension String {
    
    func insecureMD5Hash(using encoding: String.Encoding = .utf8) -> String? {
        return self.hash(algo: Insecure.MD5.self, using: encoding)
    }
    
    func insecureSHA1Hash(using encoding: String.Encoding = .utf8) -> String? {
        return self.hash(algo: Insecure.SHA1.self, using: encoding)
    }
    
    private func hash<Hash: HashFunction & ByteCountable>(algo: Hash.Type, using encoding: String.Encoding = .utf8) -> String? {
        guard let data = self.data(using: encoding) else {
            return nil
        }
        
        return algo.hash(data: data).prefix(algo.byteCount).map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}

public struct JazzavatarView: View {
    let jazzavatar: Jazzavatar
    
    public init(name: String) {
        self.jazzavatar = Jazzavatar(name: name)
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let sideLength = min(proxy.size.width, proxy.size.height)

            ZStack {
                ForEach(jazzavatar.segments, id: \.self) {segment  in
                    Rectangle().fill(Color(rgba: segment.color))
                        .frame(width: sideLength, height: sideLength)
                        .rotationEffect(.init(degrees: segment.rotate))
                        .offset(
                            x: sideLength * segment.offsetX,
                            y: sideLength * segment.offsetY
                        )
                }
            }
            .frame(width: sideLength, height: sideLength)
            .background(Color(rgba: jazzavatar.backgroundColorName))
            .clipped()
        }
    }
}

struct JazzavatarView_Previews: PreviewProvider {
    static var previews: some View {
        JazzavatarView(name: "rushairer")
    }
}
