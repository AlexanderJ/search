//
//  ContentView.swift
//  Shared
//
//  Created by Alexander Jährling on 31.05.22.
//

import SwiftUI

func getStringWidth(font: Font?, str: String) -> CGFloat {
    let str = "Hello!"

    let uiFont = UIFont.preferredFont(forTextStyle: .largeTitle)
    let ctFont = CTFontCreateWithName(uiFont.fontName as CFString, 100.0, nil)
    
    var unichars = [UniChar](str.utf16)
    var glyphs = [CGGlyph](repeating: 0, count: unichars.count)

    guard CTFontGetGlyphsForCharacters(
        ctFont,    // font: CTFont
        &unichars, // characters: UnsafePointer<UniChar>
        &glyphs,   // UnsafeMutablePointer<CGGlyph>
        unichars.count // count: CFIndex
        )
        else {
        return .zero
    }

    let glyphsCount = glyphs.count
    var advances = [CGSize](
        repeating: CGSize(width: 0.0, height: 0.0),
        count: glyphsCount
    )
    let width = CTFontGetAdvancesForGlyphs(
        ctFont,      // font: CTFont
        CTFontOrientation.horizontal, // orientation: CFFontOrientation
        glyphs,      // glyphs: UnsafePointer<CGGlyph>
        &advances,   // advances: UnsafeMutablePointer<CGSize>?
        glyphsCount // count: CFIndex
    )
    print("width=\(width)")
    print("advances=\(advances)")

    var boundingRects = [CGRect](
        repeating: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0),
        count: glyphsCount
    )

    // Result: font design metrics transformed into font space.
    let boundingBox = CTFontGetBoundingRectsForGlyphs(
        ctFont,         // font: CTFont
        .horizontal,    // orientation: CFFontOrientation
        glyphs,         // glyphs: UnsafePointer<CGGlyph>
        &boundingRects, // boundingRects: UnsafeMutablePointer<CGRect>?
        glyphsCount     // count: CFIndex
    )
    print("boundingBox=\(boundingBox)")
    print("boundingRects=\(boundingRects)")
    return boundingBox.width
}

struct TextView: View {
    @Environment(\.font) var font
    
    var text = [
        "Hallo", "dies", "ist", "ein", "langer", "Text,", "der",
        "umgebrochen", "werden", "soll.", "Hier", "geht's", "noch",
        "weiter."]
    
    func items(maxWidth: CGFloat) -> [(String, CGPoint)] {
        var x = CGFloat.zero
        var y = CGFloat.zero
        //let font = UIFont.preferredFont(forTextStyle: .body)
        //let ctFont = font! as CTFont
        let values : [(String, CGPoint)] = text.map { str in
            let width = getStringWidth(font: font, str: str)
            if x + width > maxWidth {
                x = CGFloat.zero
                y += 20
            }
            let value = (str, CGPoint(x: x, y: y))
            x += width
            return value
        }
        print(values)
        return values
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(items(maxWidth: proxy.frame(in: .local).width), id: \.self.0) { item in
                    Text(item.0)
                        .contextMenu {
                            Text("Explanation")
                        }
                        .position(x: item.1.x, y: item.1.y)
                }
            }
            .padding()
        }
    }
}

struct ContentView: View {
    @State var searchText = ""
    @State var selection = 0
    
    var body: some View {
        NavigationView {
            VStack {
                TextView()
                    .padding()
                    .contextMenu {
                        Text("Explanation")
                    }
                List {
                    Text("Hello, world!")
                        .badge(/*@START_MENU_TOKEN@*/"Label"/*@END_MENU_TOKEN@*/)
                    Text("Hello, world!")
                        .help("Help")
                }
                .frame(minWidth: 300, minHeight: 480)
                .searchable(text: $searchText, placement: .automatic, prompt: "Enter here") {
                    Text("suggestion")
                        .searchCompletion("suggestion")
                    Picker("title", selection: $selection) {
                        Text("One").tag(1)
                        Text("Two").tag(2)
                        Text("Three").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Spacer()
                Text("Hello, world!")
                    .contextMenu {
                        Text("Explanation")
                    }

            }
            //.padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
