//
//  Funcs.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 16.08.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
//

import Foundation

public func debounce(queue: DispatchQueue = .main, delay: Double, closure: @escaping() -> Void) {
	queue.asyncAfter(deadline: .now() + delay) {
		closure()
	}
}

public func debounceTask(queue: DispatchQueue = .main, delay: Double, closure: @escaping() -> Void) -> DispatchWorkItem {
	let work = DispatchWorkItem(block: { [closure] in
		closure()
	})
	queue.asyncAfter(deadline: .now() + delay, execute: work)
	return work
}
