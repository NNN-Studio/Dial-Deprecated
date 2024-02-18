//
//  MainController.swift
//  Dial
//
//  Created by KrLite on 2024/2/11.
//

import Foundation
import SFSafeSymbols
import AppKit

class MainController: Controller {
    
    var id: ControllerID = .default(.main)
    
    var name: String = NSLocalizedString("Controllers/Default/Main/Name", value: "Main", comment: "main controller")
    
    var representingSymbol: SFSymbol = .hockeyPuck
    
    var haptics: Bool = false
    
    var callback: Dial.Callback?
    
    var isAgent: Bool {
        get {
            state.isAgent
        }
        
        set {
            state = newValue ? .agentPressing : .notAgent
        }
    }
    
    private var state: State = .notAgent
    
    private var dispatch: DispatchWorkItem?
    
    enum State {
        
        case agentPressing
        
        case agentPressingRotated
        
        case agentReleased
        
        case notAgent
        
        var isAgent: Bool {
            switch self {
            case .notAgent:
                false
            default:
                true
            }
        }
        
    }
    
    func onClick(isDoubleClick: Bool, interval: TimeInterval?, _ callback: Dial.Callback) {
        state = .agentPressingRotated
    }
    
    func onRelease(_ callback: Dial.Callback) {
        if state == .agentPressing {
            state = .agentReleased
        }
        
        if state == .agentPressingRotated {
            discardAgentRole()
        }
    }
    
    func onRotation(
        rotation: Rotation, totalDegrees: Int,
        buttonState: Device.ButtonState, interval: TimeInterval?, duration: TimeInterval,
        _ callback: Dial.Callback
    ) {
        if state == .agentPressing {
            state = .agentPressingRotated
        }
        
        switch rotation {
        case .continuous(_):
            break
        case .stepping(let direction):
            Controllers.cycleThroughControllers(direction.physical.negate.rawValue)
            callback.device.buzz()
        }
    }
    
    func willBeAgent() {
        dispatch = DispatchWorkItem {
            self.isAgent = true
            self.callback?.window.show()
            self.callback?.device.buzz()
            
            print("Default controller is now the agent.")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + NSEvent.doubleClickInterval, execute: dispatch!)
    }
    
    func discardUpcomingAgentRole() {
        dispatch?.cancel()
    }
    
    func discardAgentRole() {
        discardUpcomingAgentRole()
        
        if isAgent {
            isAgent = false
            self.callback?.window.hide()
            
            print("Default controller is no longer the agent.")
        }
    }
    
}
