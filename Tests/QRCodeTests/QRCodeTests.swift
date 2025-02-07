import XCTest
@testable import QRCode
@testable import QRCode3rdPartyGenerator

final class QRCodeTests: XCTestCase {

	private func performTest(closure: () throws -> Void) {
		do {
			try closure()
		}
		catch {
			XCTFail("Unexpected error thrown: \(error)")
		}
	}

#if !os(watchOS)
	func testBasicQRCode() throws {
		let doc = QRCode()
		let url = URL(string: "https://www.apple.com.au/")!
		doc.update(message: QRCode.Message.Link(url), errorCorrection: .high)

		let boomat = doc.boolMatrix
		XCTAssertEqual(35, boomat.dimension)

		// Convert to image and detect qr codes
		do {
			let imaged = try XCTUnwrap(doc.cgImage(CGSize(width: 600, height: 600)))
			let features = QRCode.Detect(imaged)
			let first = features[0]
			XCTAssertEqual("https://www.apple.com.au/", first.messageString)
		}

		let design = QRCode.Design()
		design.shape.data = QRCode.DataShape.Squircle()
		design.shape.eye = QRCode.EyeShape.RoundedPointingIn()

		do {
			let img = try XCTUnwrap(doc.cgImage(CGSize(width: 500, height: 500), design: design))
			let features = QRCode.Detect(img)
			let first = features[0]
			XCTAssertEqual("https://www.apple.com.au/", first.messageString)
		}
	}
#endif
	
	func testAsciiGenerationWorks() throws {
		let doc = QRCode.Document()
		doc.errorCorrection = .low
		doc.data = "testing".data(using: .utf8)!
		let ascii = doc.asciiRepresentation
		Swift.print(ascii)

		let doc2 = QRCode.Document()
		doc2.errorCorrection = .low
		doc2.data = "testing".data(using: .utf8)!
		let ascii2 = doc2.smallAsciiRepresentation
		Swift.print(ascii2)
	}

	func testDSFGradient() {
		let gps1 = [
			DSFGradient.Pin(CGColor.white, 1.0),
			DSFGradient.Pin(CGColor.black, 0.0),
			DSFGradient.Pin(CGColor(red: 1, green: 1, blue: 0, alpha: 1.0), 0.2),
		]
		let g1 = DSFGradient(pins: gps1)
		let arc = try! XCTUnwrap(g1?.asRGBAGradientString())
		let g11 = try! XCTUnwrap(DSFGradient.FromRGBAGradientString(arc))

		XCTAssertEqual(g11.pins[0].position, 0.0)
		XCTAssertEqual(g11.pins[1].position, 0.2)
		XCTAssertEqual(g11.pins[2].position, 1.0)

		let g11c = g11.copyGradient()
		XCTAssertEqual(g11c.pins[0].position, 0.0)
		XCTAssertEqual(g11c.pins[1].position, 0.2)
		XCTAssertEqual(g11c.pins[2].position, 1.0)
	}

	func testBasicEncodeDecode() throws {
		do {
			let doc1 = QRCode.Document()
			doc1.data = "this is a test".data(using: .utf8)!

			let s = doc1.settings()
			let doc11 = try QRCode.Document.Create(settings: s)
			XCTAssertNotNil(doc11)

			let data = try XCTUnwrap(doc1.jsonData())
			let dataStr = try XCTUnwrap(doc1.jsonStringFormatted())

			let doc111 = try XCTUnwrap(QRCode.Document.Create(jsonData: data))
			XCTAssertNotNil(doc111)
			let data111Str = try XCTUnwrap(doc111.jsonStringFormatted())
			XCTAssertEqual(dataStr, data111Str)
		}
		catch {
			fatalError("Caught exception")
		}
	}

	func testBasicCreate() throws {
		do {
			let doc = QRCode.Document(utf8String: "Hi there!", errorCorrection: .high)
			doc.design.backgroundColor(CGColor.clear)
			doc.design.foregroundColor(CGColor.white)
			let image = doc.cgImage(CGSize(width: 800, height: 800))
			let _ = try XCTUnwrap(image)
		}
	}
}
