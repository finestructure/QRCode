//
//  QRCodeDataShapeVertical.swift
//
//  Created by Darren Ford on 17/11/21.
//  Copyright © 2022 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import CoreGraphics
import Foundation

public extension QRCode.DataShape {
	@objc(QRCodeDataShapeVertical) class Vertical: NSObject, QRCodeDataShapeGenerator {

		static public let Name: String = "vertical"
		static public func Create(_ settings: [String: Any]?) -> QRCodeDataShapeGenerator {
			return QRCode.DataShape.Vertical(
				inset: DoubleValue(settings?["inset"]) ?? 0,
				cornerRadiusFraction: DoubleValue(settings?["cornerRadiusFraction"]) ?? 0
			)
		}

		public func settings() -> [String : Any] {
			return [
				"inset": self.inset,
				"cornerRadiusFraction": self.cornerRadiusFraction
			]
		}

		public func copyShape() -> QRCodeDataShapeGenerator {
			return Vertical(
				inset: self.inset,
				cornerRadiusFraction: self.cornerRadiusFraction
			)
		}
		
		let inset: CGFloat
		let cornerRadiusFraction: CGFloat
		@objc public init(inset: CGFloat = 0, cornerRadiusFraction: CGFloat = 0) {
			self.inset = inset
			self.cornerRadiusFraction = cornerRadiusFraction.clamped(to: 0...1)
			super.init()
		}
		
		public func onPath(size: CGSize, data: QRCode, isTemplate: Bool = false) -> CGPath {
			let dx = size.width / CGFloat(data.pixelSize)
			let dy = size.height / CGFloat(data.pixelSize)
			let dm = min(dx, dy)
			
			let xoff = (size.width - (CGFloat(data.pixelSize) * dm)) / 2.0
			let yoff = (size.height - (CGFloat(data.pixelSize) * dm)) / 2.0
			
			let path = CGMutablePath()
			
			for col in 1 ..< data.pixelSize - 1 {
				var activeRect: CGRect?
				
				for row in 1 ..< data.pixelSize - 1 {
					let isEye = data.isEyePixel(row, col) && isTemplate == false

					if data.current[row, col] == false || isEye {
						if let r = activeRect {
							// Close the rect
							let ri = r.insetBy(dx: self.inset, dy: self.inset)
							let cr = (ri.width / 2.0) * self.cornerRadiusFraction
							path.addPath(CGPath(roundedRect: ri, cornerWidth: cr, cornerHeight: cr, transform: nil))
						}
						activeRect = nil
						continue
					}
					
					if var a = activeRect {
						a.size.height += dm
						activeRect = a
					}
					else {
						activeRect = CGRect(x: xoff + (CGFloat(col) * dm), y: yoff + (CGFloat(row) * dm), width: dm, height: dm)
					}
				}
				
				if let r = activeRect {
					// Close the rect
					let ri = r.insetBy(dx: self.inset, dy: self.inset)
					let cr = (ri.width / 2.0) * self.cornerRadiusFraction
					path.addPath(CGPath(roundedRect: ri, cornerWidth: cr, cornerHeight: cr, transform: nil))
				}
			}
			return path
		}
		
		public func offPath(size: CGSize, data: QRCode, isTemplate: Bool = false) -> CGPath {
			let dx = size.width / CGFloat(data.pixelSize)
			let dy = size.height / CGFloat(data.pixelSize)
			let dm = min(dx, dy)
			
			let xoff = (size.width - (CGFloat(data.pixelSize) * dm)) / 2.0
			let yoff = (size.height - (CGFloat(data.pixelSize) * dm)) / 2.0
			
			let path = CGMutablePath()
			
			for col in 0 ..< data.pixelSize {
				var activeRect: CGRect?
				
				for row in 0 ..< data.pixelSize {
					let isEye = data.isEyePixel(row, col) && isTemplate == false

					if data.current[row, col] == true || isEye {
						if let r = activeRect {
							// Close the rect
							let ri = r.insetBy(dx: self.inset, dy: self.inset)
							let cr = (ri.width / 2.0) * self.cornerRadiusFraction
							path.addPath(CGPath(roundedRect: ri, cornerWidth: cr, cornerHeight: cr, transform: nil))
						}
						activeRect = nil
						continue
					}
					
					if var a = activeRect {
						a.size.height += dm
						activeRect = a
					}
					else {
						activeRect = CGRect(x: xoff + (CGFloat(col) * dm), y: yoff + (CGFloat(row) * dm), width: dm, height: dm)
					}
				}
				
				if let r = activeRect {
					// Close the rect
					let ri = r.insetBy(dx: self.inset, dy: self.inset)
					let cr = (ri.width / 2.0) * self.cornerRadiusFraction
					path.addPath(CGPath(roundedRect: ri, cornerWidth: cr, cornerHeight: cr, transform: nil))
				}
			}
			return path
		}
	}
}
