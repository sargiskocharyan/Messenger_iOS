
import AVFoundation
import CallKit

class ProviderDelegate: NSObject {
  private let callManager: CallManager
  private let provider: CXProvider
  
  init(callManager: CallManager) {
    self.callManager = callManager
    provider = CXProvider(configuration: ProviderDelegate.providerConfiguration)
    
    super.init()

    provider.setDelegate(self, queue: nil)
  }
  
  static var providerConfiguration: CXProviderConfiguration = {
    let providerConfiguration = CXProviderConfiguration(localizedName: "Hotline")
    providerConfiguration.supportsVideo = true
    providerConfiguration.maximumCallsPerCallGroup = 1
    providerConfiguration.supportedHandleTypes = [.phoneNumber]
    return providerConfiguration
  }()
  
  func reportIncomingCall(
    id: String,
    uuid: UUID,
    handle: String,
    hasVideo: Bool = false,
    roomName: String,
    completion: ((Error?) -> Void)?
  ) {
    let update = CXCallUpdate()
    update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
    update.hasVideo = hasVideo
    provider.reportNewIncomingCall(with: uuid, update: update) { error in
      if error == nil {
        let call = Call(id: id, uuid: uuid, handle: handle, roomName: roomName)
        self.callManager.add(call: call)
      }
      
      completion?(error)
    }
  }
}

// MARK: - CXProviderDelegate
extension ProviderDelegate: CXProviderDelegate {
  func providerDidReset(_ provider: CXProvider) {
    stopAudio()
    
    for call in callManager.calls {
      call.end()
    }
    
    callManager.removeAllCalls()
  }
  
  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
      action.fail()
      return
    }
    
    configureAudioSession()
//    provider.configuration.
    call.answer()

    action.fulfill()
    SocketTaskManager.shared.callAccepted(id: call.id, isAccepted: true)
    
  }
  
  func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
    startAudio()
  }
  
  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
      action.fail()
      return
    }
    
    stopAudio()
    
    call.end()

    action.fulfill()

    callManager.remove(call: call)
    SocketTaskManager.shared.callAccepted(id: call.id, isAccepted: false)
  }
  
  func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
    guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
      action.fail()
      return
    }
    call.state = action.isOnHold ? .held : .active
    if call.state == .held {
      stopAudio()
    } else {
      startAudio()
    }
    action.fulfill()
  }
  
  func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
    let call = Call(id: "", uuid: action.callUUID, outgoing: true,
                    handle: action.handle.value, roomName: "")

    configureAudioSession()

    call.connectedStateChanged = { [weak self, weak call] in
      guard
        let self = self,
        let call = call
        else {
          return
      }
      
      if call.connectedState == .pending {
        self.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: nil)
      } else if call.connectedState == .complete {
        self.provider.reportOutgoingCall(with: call.uuid, connectedAt: nil)
      }
    }

    call.start { [weak self, weak call] success in
      guard
        let self = self,
        let call = call
        else {
          return
      }
      
      if success {
        action.fulfill()
        self.callManager.add(call: call)
      } else {
        action.fail()
      }
    }
  }
}
