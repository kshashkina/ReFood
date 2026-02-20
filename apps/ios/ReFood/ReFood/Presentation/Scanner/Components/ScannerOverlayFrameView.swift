import SwiftUI

struct ScannerOverlayFrameView: View {

    private let accent = Color(red: 144/255, green: 240/255, blue: 71/255)

    var body: some View {
        ZStack {
            corner(top: true, left: true)
                .frame(width: 48, height: 48)
                .position(x: 24, y: 24)

            corner(top: true, left: false)
                .frame(width: 48, height: 48)
                .position(x: 288 - 24, y: 24)

            corner(top: false, left: true)
                .frame(width: 48, height: 48)
                .position(x: 24, y: 400 - 24)

            corner(top: false, left: false)
                .frame(width: 48, height: 48)
                .position(x: 288 - 24, y: 400 - 24)
        }
    }

    private func corner(top: Bool, left: Bool) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .trim(from: 0, to: 0.25)
            .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .foregroundStyle(accent)
            .rotationEffect(.degrees(rotation(top: top, left: left)))
    }

    private func rotation(top: Bool, left: Bool) -> Double {
        switch (top, left) {
        case (true, true): return 180
        case (true, false): return 270
        case (false, true): return 90
        case (false, false): return 0
        }
    }
}
