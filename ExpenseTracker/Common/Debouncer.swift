//
//  Debouncer.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//


import Foundation

final class Debouncer {
	
	private let delay: TimeInterval
	private var timer: Timer?
	
	var handler: () -> Void
	
	init(delay: TimeInterval, handler: @escaping () -> Void) {
		self.delay = delay
		self.handler = handler
	}
	
	func call() {
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { [weak self] _ in
			self?.handler()
		})
	}
	
	func invalidate() {
		timer?.invalidate()
		timer = nil
	}
	
}
