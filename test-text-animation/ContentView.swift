//
//  ContentView.swift
//  test-text-animation
//
//  Created by Tomas Kafka on 21.12.2022.
//

import Foundation
import SwiftUI

// MARK: - Debug

public struct DebugFrame: ViewModifier {
	var color: UIColor
	var lineWidth: CGFloat = 1

	public func body(content: Content) -> some View {
		content
			.overlay(
				Rectangle()
					.strokeBorder(Color(color), lineWidth: lineWidth)
					.allowsHitTesting(false)
			)
	}
}

public extension View {
	func debugFrame(_ color: UIColor = .purple, lineWidth: CGFloat = 1) -> some View {
		modifier(DebugFrame(color: color, lineWidth: lineWidth))
	}
}

// MARK: - Backport

public struct Backport<Content> {
	let content: Content
}

public extension View {
	var backport: Backport<Self> { Backport(content: self) }
}

public extension Backport where Content: View {
	@ViewBuilder func contentTransitionNumericText() -> some View {
		if #available(iOS 16.0, watchOS 9.0, tvOS 16.0, macCatalyst 16.0, macOS 13.0, *) {
			content
				.contentTransition(.numericText())
		} else {
			content
		}
	}

	@ViewBuilder func contentTransitionIdentity() -> some View {
		if #available(iOS 16.0, watchOS 9.0, tvOS 16.0, macCatalyst 16.0, macOS 13.0, *) {
			content
				.contentTransition(.identity)
		} else {
			content
		}
	}
	
	@ViewBuilder func contentTransitionInterpolate() -> some View {
		if #available(iOS 16.0, watchOS 9.0, tvOS 16.0, macCatalyst 16.0, macOS 13.0, *) {
			content
				.contentTransition(.interpolate)
		} else {
			content
		}
	}
}


// MARK: - Random symbols

let symbols: [String] = [
	"ellipsis.circle.fill",
	"heart.fill",
	"cloud.fill",
	"checkmark.circle.fill",
	"bolt.fill"
]

func randomItem<T>(from array: [T]) -> T? {
	guard !array.isEmpty else { return nil }
	let randomIndex = Int.random(in: 0 ..< array.count)
	return array[randomIndex]
}


// MARK: - Views

extension CGPoint {
	func rounded(_ rounding: CGFloat) -> CGPoint {
		return .init(
			x: (x / rounding).rounded() * rounding,
			y: (y / rounding).rounded() * rounding
		)
	}
}

struct SymbolView: View {
	var systemName: String
	var size: CGFloat

	var body: some View {
		ZStack(alignment: .center) {
			Image(systemName: systemName)
			// .resizable()
				.id("symbol")
				.backport.contentTransitionIdentity() /// `contentTransitionInterpolate()` doesn't help either
		}
		.frame(width: size, height: size)
		.id("zstack")
		.backport.contentTransitionIdentity() /// `contentTransitionInterpolate()` doesn't help either
	}
}


struct FollowFingerText: View {
	@State private var currentPosition: CGPoint = .zero

	let circleSize: CGFloat = 44
	let rounding: CGFloat = 20

	let version = UIDevice.current.systemVersion
	var hint: String {
		if version.starts(with: "15") {
			return "iOS \(version): changing symbol animates its position smoothly"
		} else {
			return "iOS \(version): once the symbol changes, it is recreated at new origin for every animation step"
		}
	}

	var body: some View {
		GeometryReader { _ in
			VStack(alignment: .leading) {
				Text("Static text.")
					.font(.headline)
					.id("text1")
					.animation(.default, value: currentPosition)

				Text("Dynamic: \(Int(currentPosition.x)),\(Int(currentPosition.y))")
					.font(.headline)
					// .animation(nil, value: 1) /// doesn't help
					.id("text2")
					.animation(.default, value: currentPosition)

				Text(hint)
					.font(.footnote)
					.id("hint")

				if let randomSymbol = randomItem(from: symbols) {
					SymbolView(systemName: randomSymbol, size: 32)
						.id("symbol")
				}

				Circle()
					.fill(.red)
					.frame(width: circleSize, height: circleSize)
					.id("circle")
					.animation(.default, value: currentPosition)
			}
			.frame(maxWidth: 180, alignment: .topLeading)
			.offset(x: currentPosition.x, y: currentPosition.y)
			.backport.contentTransitionIdentity()
			// .contentTransition(.identity)
		} /// geo reader
		.contentShape(Rectangle())
		.gesture(
			DragGesture()
				.onChanged { value in
					let roundedPoint = value.location.rounded(rounding)
					if self.currentPosition != roundedPoint {
						withAnimation {
							self.currentPosition = roundedPoint
						}
					}
				}
		)
		.debugFrame(.red)
	}
}

struct ContentView: View {
	var body: some View {
		FollowFingerText()
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
