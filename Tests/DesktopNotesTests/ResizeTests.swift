import Foundation
import Testing
@testable import DesktopNotes

struct ResizeTests {
    let initial = CGRect(x: 100, y: 200, width: 320, height: 360)
    let minimum = CGSize(width: 240, height: 180)
    let maximum = CGSize(width: 700, height: 850)

    @Test func draggingCornerKeepsTopLeftAnchored() {
        let result = resize(dx: 100, dy: -80)
        #expect(result == CGRect(x: 100, y: 120, width: 420, height: 440))
        #expect(result.minX == initial.minX)
        #expect(result.maxY == initial.maxY)
    }

    @Test func shrinkingStopsBeforeTextAreaCollapses() {
        #expect(resize(dx: -1000, dy: 1000).size == minimum)
    }

    @Test func enlargingRespectsWindowMaximum() {
        #expect(resize(dx: 1000, dy: -1000).size == maximum)
    }

    @Test func cornerCannotCrossScreenEdges() {
        let screen = CGRect(x: -500, y: 0, width: 1100, height: 800)
        let result = resize(dx: 1000, dy: -1000, screen: screen)
        #expect(result.maxX == screen.maxX)
        #expect(result.minY == screen.minY)
        #expect(result.maxY == initial.maxY)
    }

    private func resize(dx: CGFloat, dy: CGFloat, screen: CGRect? = nil) -> CGRect {
        NoteResize.frame(from: initial, delta: CGPoint(x: dx, y: dy),
                         minimum: minimum, maximum: maximum, screen: screen)
    }
}
