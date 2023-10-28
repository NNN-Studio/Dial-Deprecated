
import Foundation

protocol Controller: AnyObject {
    
    func hapticsMode() -> Dial.HapticsMode
    
    func onMouseDown(last: TimeInterval?)
    
    func onMouseUp(last: TimeInterval?)
    
    func onRotation(_ rotation: Dial.Rotation, _ direction: Direction, last: TimeInterval?)
    
}
