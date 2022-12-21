//
//  ContentView.swift
//  test-text-animation
//
//  Created by Tomas Kafka on 21.12.2022.
//

import SwiftUI

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

extension CGPoint {
	func rounded(_ rounding: CGFloat) -> CGPoint {
		return .init(
			x: (self.x / rounding).rounded() * rounding,
			y: (self.y / rounding).rounded() * rounding
		)
	}
}

struct FollowFingerText: View {
	@State private var currentPosition: CGPoint = .zero
	
	let circleSize: CGFloat = 44
	let rounding: CGFloat = 20
	
	var body: some View {
		GeometryReader { proxy in
			VStack() {
				Text("Static text.")
					.font(.title)
					.offset(x: currentPosition.x, y: currentPosition.y)
					.id("text1")
					.animation(.default, value: currentPosition)
				
				Text("Dynamic: \(Int(currentPosition.x)),\(Int(currentPosition.y))")
					.font(.title)
					// .animation(nil, value: 1) /// doesn't help
					.offset(x: currentPosition.x, y: currentPosition.y)
					.id("text2")
					.animation(.default, value: currentPosition)

				Circle()
					.fill(.red)
					.frame(width: circleSize, height: circleSize)
					.offset(x: currentPosition.x, y: currentPosition.y)
					.id("circle")
					.animation(.default, value: currentPosition)

			}
			.frame(alignment: .topLeading)
			.debugFrame()
			
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
