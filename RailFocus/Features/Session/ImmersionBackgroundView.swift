//
//  ImmersionBackgroundView.swift
//  RailFocus
//
//  Animated immersive background for train journey sessions.
//  Features: Sky gradient shifts, parallax landscape, tunnel effects.
//

import SwiftUI

// MARK: - Immersion Background View

struct ImmersionBackgroundView: View {
    let progress: Double // 0.0 to 1.0
    let isInTunnel: Bool
    let phase: JourneyPhase

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var landscapeOffset: CGFloat = 0
    @State private var nearLandscapeOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Layer 1: Sky gradient (shifts over time)
            skyGradient
                .ignoresSafeArea()

            // Layer 2: Distant landscape (slow parallax)
            if !reduceMotion {
                distantLandscape
                    .offset(x: landscapeOffset)
            }

            // Layer 3: Near landscape (faster parallax)
            if !reduceMotion {
                nearLandscape
                    .offset(x: nearLandscapeOffset)
            }

            // Layer 4: Tunnel overlay
            if isInTunnel {
                tunnelOverlay
                    .transition(.opacity)
            }

            // Layer 5: Subtle grain/noise overlay
            noiseOverlay
                .opacity(0.03)
        }
        .animation(.easeInOut(duration: 0.8), value: isInTunnel)
        .onAppear {
            if !reduceMotion {
                startParallaxAnimation()
            }
        }
    }

    // MARK: - Sky Gradient

    private var skyGradient: some View {
        LinearGradient(
            colors: skyColors,
            startPoint: .top,
            endPoint: .bottom
        )
        .animation(.easeInOut(duration: 2.0), value: progress)
    }

    private var skyColors: [Color] {
        // Shift sky colors based on progress: dawn → day → dusk
        switch progress {
        case 0..<0.15:
            // Dawn - soft oranges and purples
            return [
                Color(hex: "1a1a2e"),
                Color(hex: "16213e"),
                Color(hex: "0f3460")
            ]

        case 0.15..<0.35:
            // Morning - brightening blues
            return [
                Color(hex: "0f3460"),
                Color(hex: "1a508b"),
                Color(hex: "0d7377")
            ]

        case 0.35..<0.65:
            // Midday - clear sky blue
            return [
                Color(hex: "1a508b"),
                Color(hex: "0077b6"),
                Color(hex: "00b4d8")
            ]

        case 0.65..<0.85:
            // Afternoon - warmer tones
            return [
                Color(hex: "023e8a"),
                Color(hex: "0077b6"),
                Color(hex: "48cae4")
            ]

        case 0.85...1.0:
            // Dusk - golden hour
            return [
                Color(hex: "1a1a2e"),
                Color(hex: "2d2d44"),
                Color(hex: "4a4e69")
            ]

        default:
            return [
                Color(hex: "0f3460"),
                Color(hex: "1a508b"),
                Color(hex: "0d7377")
            ]
        }
    }

    // MARK: - Distant Landscape (Slow Parallax)

    private var distantLandscape: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                drawDistantHills(context: context, size: size)
            }
            .opacity(0.15)
        }
    }

    private func drawDistantHills(context: GraphicsContext, size: CGSize) {
        let hillCount = 5
        let baseY = size.height * 0.7

        for i in 0..<hillCount {
            var path = Path()
            let xOffset = CGFloat(i) * size.width / CGFloat(hillCount - 1)
            let height = CGFloat.random(in: 80...150)

            path.move(to: CGPoint(x: xOffset - 100, y: baseY))

            // Create smooth hill curve
            path.addQuadCurve(
                to: CGPoint(x: xOffset + 100, y: baseY),
                control: CGPoint(x: xOffset, y: baseY - height)
            )

            path.addLine(to: CGPoint(x: xOffset + 100, y: size.height))
            path.addLine(to: CGPoint(x: xOffset - 100, y: size.height))
            path.closeSubpath()

            context.fill(path, with: .color(.white.opacity(0.3)))
        }
    }

    // MARK: - Near Landscape (Fast Parallax)

    private var nearLandscape: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                drawNearElements(context: context, size: size)
            }
            .opacity(0.1)
        }
    }

    private func drawNearElements(context: GraphicsContext, size: CGSize) {
        // Draw telegraph poles / trees
        let elementCount = 8
        let baseY = size.height * 0.85

        for i in 0..<elementCount {
            let xPos = CGFloat(i) * (size.width / CGFloat(elementCount - 1))
            var path = Path()

            // Simple vertical line (telegraph pole)
            path.move(to: CGPoint(x: xPos, y: baseY))
            path.addLine(to: CGPoint(x: xPos, y: baseY - 60))

            context.stroke(path, with: .color(.white.opacity(0.4)), lineWidth: 2)
        }
    }

    // MARK: - Tunnel Overlay

    private var tunnelOverlay: some View {
        ZStack {
            // Dark vignette
            RadialGradient(
                colors: [
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.9)
                ],
                center: .center,
                startRadius: 100,
                endRadius: 400
            )

            // Whoosh lines effect
            WhooshLinesView()
                .opacity(0.3)
        }
    }

    // MARK: - Noise Overlay

    private var noiseOverlay: some View {
        Canvas { context, size in
            for _ in 0..<500 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Rectangle().path(in: rect), with: .color(.white))
            }
        }
    }

    // MARK: - Parallax Animation

    private func startParallaxAnimation() {
        // Distant landscape moves slowly
        withAnimation(
            .linear(duration: 30)
            .repeatForever(autoreverses: false)
        ) {
            landscapeOffset = -500
        }

        // Near landscape moves faster
        withAnimation(
            .linear(duration: 15)
            .repeatForever(autoreverses: false)
        ) {
            nearLandscapeOffset = -800
        }
    }
}

// MARK: - Whoosh Lines View (Tunnel Effect)

struct WhooshLinesView: View {
    @State private var animating = false

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<12, id: \.self) { index in
                WhooshLine(index: index, animating: animating)
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 0.5)
                .repeatForever(autoreverses: false)
            ) {
                animating = true
            }
        }
    }
}

struct WhooshLine: View {
    let index: Int
    let animating: Bool

    var body: some View {
        GeometryReader { geometry in
            let angle = Double(index) * (360.0 / 12.0)
            let length = geometry.size.width * 0.4

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.5), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: length, height: 2)
                .rotationEffect(.degrees(angle))
                .offset(
                    x: animating ? geometry.size.width * 0.3 : 0,
                    y: 0
                )
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
        }
    }
}

// MARK: - Stars Background (Enhanced)

struct StarsBackgroundView: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<100 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let starSize = CGFloat.random(in: 1...3)
                let opacity = Double.random(in: 0.3...0.8)

                let rect = CGRect(
                    x: x - starSize/2,
                    y: y - starSize/2,
                    width: starSize,
                    height: starSize
                )
                context.fill(
                    Circle().path(in: rect),
                    with: .color(.white.opacity(opacity))
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ImmersionBackgroundView(
        progress: 0.5,
        isInTunnel: false,
        phase: .cruising
    )
}

#Preview("Tunnel") {
    ImmersionBackgroundView(
        progress: 0.35,
        isInTunnel: true,
        phase: .cruising
    )
}
