//
//  Debouncer.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 08.11.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
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
