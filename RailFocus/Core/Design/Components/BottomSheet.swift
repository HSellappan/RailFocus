//
//  BottomSheet.swift
//  RailFocus
//
//  Bottom sheet modal component
//

import SwiftUI

struct RFBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String?
    let showHandle: Bool
    let content: () -> Content

    init(
        isPresented: Binding<Bool>,
        title: String? = nil,
        showHandle: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.title = title
        self.showHandle = showHandle
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Backdrop
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(RFAnimation.standard) {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)
            }

            // Sheet content
            if isPresented {
                VStack(spacing: 0) {
                    // Handle
                    if showHandle {
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(Color.rfAdaptiveTextTertiary.opacity(0.5))
                            .frame(width: 36, height: 5)
                            .padding(.top, RFSpacing.sm)
                            .padding(.bottom, RFSpacing.xs)
                    }

                    // Title
                    if let title = title {
                        Text(title)
                            .font(RFTypography.headline.font)
                            .foregroundStyle(Color.rfAdaptiveTextPrimary)
                            .padding(.top, showHandle ? RFSpacing.sm : RFSpacing.lg)
                            .padding(.bottom, RFSpacing.md)
                    }

                    // Content
                    content()
                        .padding(.bottom, RFSpacing.lg)
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: RFCornerRadius.xl)
                        .fill(Color.rfAdaptiveSurface)
                        .ignoresSafeArea(edges: .bottom)
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(RFAnimation.standard, value: isPresented)
    }
}

// MARK: - Bottom Sheet Modifier

struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let title: String?
    let showHandle: Bool
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        ZStack {
            content

            RFBottomSheet(
                isPresented: $isPresented,
                title: title,
                showHandle: showHandle,
                content: sheetContent
            )
        }
    }
}

extension View {
    func rfBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        title: String? = nil,
        showHandle: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            BottomSheetModifier(
                isPresented: isPresented,
                title: title,
                showHandle: showHandle,
                sheetContent: content
            )
        )
    }
}

// MARK: - Preview

#Preview("Bottom Sheet") {
    struct PreviewWrapper: View {
        @State private var showSheet = false

        var body: some View {
            ZStack {
                Color.rfAdaptiveBackground
                    .ignoresSafeArea()

                VStack {
                    PrimaryButton("Show Sheet") {
                        showSheet = true
                    }
                    .padding()
                }
            }
            .rfBottomSheet(isPresented: $showSheet, title: "Select Duration") {
                VStack(spacing: RFSpacing.md) {
                    HStack(spacing: RFSpacing.sm) {
                        DurationPill(minutes: 25, isSelected: false) {}
                        DurationPill(minutes: 45, isSelected: true) {}
                        DurationPill(minutes: 60, isSelected: false) {}
                    }

                    PrimaryButton("Confirm") {
                        showSheet = false
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    return PreviewWrapper()
}
