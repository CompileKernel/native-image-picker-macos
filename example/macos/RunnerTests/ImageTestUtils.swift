import AppKit

func createTestImage(size: NSSize) -> NSImage {
  let image = NSImage(size: size)
  image.lockFocus()
  NSColor.white.set()
  NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
  image.unlockFocus()
  return image
}
