//
//  View+Extensions.swift
//  RailFocus
//
//  SwiftUI View extensions
//

import SwiftUI

// MARK: - Conditional Modifiers

extension View {
    /// Apply a modifier conditionally
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Apply different modifiers based on condition
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        ifTrue: (Self) -> TrueContent,
        ifFalse: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTrue(self)
        } else {
            ifFalse(self)
        }
    }
}

// MARK: - Frame Helpers

extension View {
    /// Apply horizontal padding and max width
    func screenPadding(_ horizontal: CGFloat = RFSpacing.md) -> some View {
        self
            .padding(.horizontal, horizontal)
            .frame(maxWidth: .infinity)
    }

    /// Fill entire available space
    func fillMaxSize(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
}

// MARK: - Background Helpers

extension View {
    /// Apply the app's adaptive background
    func rfBackground() -> some View {
        self.background(Color.rfAdaptiveBackground.ignoresSafeArea())
    }

    /// Apply a blurred background overlay
    func blurredBackground(
        style: Material = .ultraThinMaterial,
        cornerRadius: CGFloat = RFCornerRadius.large
    ) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(style)
        )
    }
}

// MARK: - Hide Keyboard

extension View {
    /// Hide keyboard on tap
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}

// MARK: - Safe Area

extension View {
    /// Read safe area insets
    func readSafeArea(_ safeArea: Binding<EdgeInsets>) -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SafeAreaKey.self, value: geometry.safeAreaInsets)
            }
        )
        .onPreferenceChange(SafeAreaKey.self) { value in
            safeArea.wrappedValue = value
        }
    }
}

private struct SafeAreaKey: PreferenceKey {
    static var defaultValue: EdgeInsets = .init()

    static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
        value = nextValue()
    }
}

// MARK: - Loading Overlay

extension View {
    /// Show a loading overlay
    func loadingOverlay(isLoading: Bool, message: String? = nil) -> some View {
        ZStack {
            self
                .disabled(isLoading)
                .opacity(isLoading ? 0.6 : 1)

            if isLoading {
                VStack(spacing: RFSpacing.md) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.white)

                    if let message = message {
                        Text(message)
                            .font(RFTypography.subheadline.font)
                            .foregroundStyle(.white)
                    }
                }
                .padding(RFSpacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: RFCornerRadius.large)
                        .fill(Color.black.opacity(0.7))
                )
            }
        }
        .animation(RFAnimation.quick, value: isLoading)
    }
}
