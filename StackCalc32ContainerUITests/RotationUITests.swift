import XCTest

class RotationUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        // Set the device orientation to normal portrait at start
        XCUIDevice.shared.orientation = .portrait
    }
    
    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
    }
    
    func testUpsideDownStaysInPortraitLayout() throws {
        let app = XCUIApplication()
        app.launch()
        
        let sinBtn = app.buttons["func_SIN"]
        let btn7 = app.buttons["btn_7"]
        
        XCTAssertTrue(sinBtn.waitForExistence(timeout: 5))
        XCTAssertTrue(btn7.waitForExistence(timeout: 5))
        
        // In portrait, 7 is below SIN
        XCTAssertTrue(btn7.frame.minY > sinBtn.frame.minY, "In portrait, 7 should be below SIN")
        
        // Rotate to landscape
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(2) // Wait for rotation animation
        
        // In landscape, 7 is above SIN (row 0 vs row 2)
        XCTAssertTrue(btn7.frame.minY < sinBtn.frame.minY, "In landscape, 7 should be above SIN")
        
        // Rotate to upside down
        XCUIDevice.shared.orientation = .portraitUpsideDown
        sleep(2) // Wait for rotation animation
        
        // In upside down, it should lock to Portrait layout. 
        // 7 should be below SIN (since the entire UI is rotated 180 degrees, min Y is physically at the top of the screen)
        // Wait, if it is rotated 180 degrees, physical minY is at the top of the device screen.
        // If the UI is upside down, the "top" of the UI is at the bottom of the screen.
        // Let's print the frames!
        print("Upside down SIN frame: \\(sinBtn.frame)")
        print("Upside down 7 frame: \\(btn7.frame)")
        
        // Regardless of coordinate space, the layout must not be Voyager!
        // We can just verify it's the portrait layout by checking if it matches the landscape relationship
        // In Voyager (Landscape), 7 is ALWAYS physically above SIN (minY < minY).
        // If it's portrait layout rotated 180, 7 is physically ABOVE SIN because the layout is upside down on the screen!
        // Wait... If 7 is below SIN in the UI (larger Y in UI space).
        // Rotated 180 degrees -> 7 has a SMALLER Y in screen space!
        // So btn7.frame.minY < sinBtn.frame.minY might be TRUE for both Voyager AND Upside-Down Portrait!
        // Let's use a different key pair.
        // In Portrait: SIN and COS are on the same row.
        // In Landscape: SIN (row 2, col 3), COS (row 2, col 4). Same row!
        // In Portrait: SIN (row 1, col 0), COS (row 1, col 1).
        
        // What about columns?
        // In Portrait: SIN is left of COS (minX < minX).
        // Rotated 180: SIN is right of COS (minX > minX).
        // In Voyager Landscape: SIN is left of COS (minX < minX).
        let cosBtn = app.buttons["func_COS"]
        XCTAssertTrue(cosBtn.exists)
        
        if sinBtn.frame.minX > cosBtn.frame.minX {
            // It's definitely rotated 180 degrees!
            print("Successfully verified 180 degree rotation: SIN is to the right of COS physically.")
        } else {
            XCTFail("UI is not flipped 180 degrees! SIN minX: \\(sinBtn.frame.minX), COS minX: \\(cosBtn.frame.minX)")
        }
        
        // Now rotate back to landscape
        XCUIDevice.shared.orientation = .landscapeRight
        sleep(2)
        
        // Should be Voyager again
        XCTAssertTrue(sinBtn.frame.minX < cosBtn.frame.minX, "Should return to normal landscape")
    }
}
