//
//  TDAuthState.swift
//  JSMacroChart
//
//  Created by yangjs on 11/10/25.
//

enum TDAuthState: Equatable {
    case waitingForPhoneNumber
    case waitingForCode
    case waitingForPassword
    case ready
    case loggingOut
    case unauthenticated
    
}
