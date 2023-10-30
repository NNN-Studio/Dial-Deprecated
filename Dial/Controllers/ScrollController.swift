
import Foundation
import AppKit

class ScrollController: Controller {
    
    private var currentStep = 0
    
    private var deaccelerationDispatch: DispatchWorkItem?
    
    private var continuousScrolling = (directionSignum: 1.signum(), time: Date.distantPast, count: 0, enabled: false)
    
    func onMouseDown(last: TimeInterval?, isDoubleClick: Bool) {
        deaccelerationDispatch?.cancel()
        postMouse(.left, buttonState: .pressed)
    }
    
    func onMouseUp(last: TimeInterval?, isClick: Bool) {
        postMouse(.left, buttonState: .released)
    }
    
    func onRotation(_ rotation: Device.Rotation, last: TimeInterval?, buttonState: Device.ButtonState) {
        let directionSignum = rotation.direction.rawValue
        
        if continuousScrolling.directionSignum != directionSignum {
            continuousScrolling.directionSignum = directionSignum
            continuousScrolling.time = .now
            continuousScrolling.count = 0
        } else if Date.now.timeIntervalSince(continuousScrolling.time).magnitude <= NSEvent.doubleClickInterval * 1.5 {
            continuousScrolling.count += 1
        } else {
            continuousScrolling.time = .now
            continuousScrolling.count = 0
        }
        
        continuousScrolling.enabled = continuousScrolling.count > 12
        
        deaccelerationDispatch?.cancel()
        postMouse(.left, buttonState: .released)
        
        var steps = 0
        
        switch rotation {
        case .clockwise(let d):
            steps = d
        case .counterclockwise(let d):
            steps = -d
        }
        
        let last = last?.magnitude ?? 0
        let diff = last <= NSEvent.doubleClickInterval ? last : 0
        let multiplier = Int(1 + ((150 - min(diff, 150)) / 40)) * (continuousScrolling.enabled ? 5 : 1)
        
        currentStep = steps * multiplier
        
        deaccelerationDispatch = DispatchWorkItem { [self] in
            let event = CGEvent(
                scrollWheelEvent2Source: nil,
                units: .line,
                wheelCount: 1,
                wheel1: Int32(currentStep),
                wheel2: 0,
                wheel3: 0
            )
            event?.post(tap: .cghidEventTap)
            
            currentStep /= 2
            if currentStep.magnitude > 2, let deaccelerationDispatch {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: deaccelerationDispatch)
            } else {
                deaccelerationDispatch = nil
            }
        }
        deaccelerationDispatch?.perform()
    }
    
    func onHandle() {
        postMouse(.left, buttonState: .released)
    }
    
}
