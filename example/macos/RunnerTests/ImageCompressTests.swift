import XCTest

@testable import native_image_picker_macos

final class ImageCompressTests: XCTestCase {

  func testShouldCompressImage() {
    XCTAssertFalse(shouldCompressImage(quality: 100), "Quality 100 should not compress the image.")
    XCTAssertTrue(shouldCompressImage(quality: 80), "Quality bellow 100 should compress the image.")
  }

  func testImageCompression() throws {
    let testImage = createTestImage(size: NSSize(width: 100, height: 100))

    let compressedImage = try testImage.compressed(quality: 80)

    XCTAssertLessThan(
      compressedImage.tiffRepresentation!.count, testImage.tiffRepresentation!.count,
      "Compressed image data should be smaller than the original image data.")
  }

}
