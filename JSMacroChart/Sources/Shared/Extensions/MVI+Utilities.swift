//
//  MVI+Utilities.swift
//  JSMacroChart
//
//  Created by yangjs on 9/16/25.
//

import Foundation
import SwiftUI
import Combine

import Network

// MARK: - MVI State Machine Protocol
protocol MVIState {
    associatedtype ViewState: Equatable
    var viewState: ViewState { get }
}

protocol MVIIntent {}

protocol MVIViewModel: ObservableObject {
    associatedtype State: MVIState
    associatedtype Intent: MVIIntent
    
    var state: State { get }
    func handle(intent: Intent)
}

// MARK: - Async State Management
@MainActor
final class AsyncStateManager<T> {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    private var currentTask: Task<T, Error>?
    
    func execute(
        _ operation: @escaping () async throws -> T,
        onSuccess: @escaping (T) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        // 기존 작업 취소
        currentTask?.cancel()
        
        isLoading = true
        error = nil
        
        currentTask = Task {
            do {
                let result = try await operation()
                
                if !Task.isCancelled {
                    await MainActor.run {
                        self.isLoading = false
                        onSuccess(result)
                    }
                }
                
                return result
            } catch {
                if !Task.isCancelled {
                    await MainActor.run {
                        self.isLoading = false
                        self.error = error
                        onError(error)
                    }
                }
                throw error
            }
        }
    }
    
    func cancel() {
        currentTask?.cancel()
        isLoading = false
        error = nil
    }
}

// MARK: - 디바운싱 유틸리티 (검색, 새로고침 등에 활용)
@MainActor
final class DebounceManager {
    private var task: Task<Void, Never>?
    
    func debounce(
        for duration: TimeInterval,
        action: @escaping () async -> Void
    ) {
        task?.cancel()
        
        task = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                if !Task.isCancelled {
                    await action()
                }
            } catch {
                // Task가 취소된 경우
            }
        }
    }
    
    func cancel() {
        task?.cancel()
    }
}

// MARK: - 에러 복구 전략
enum RetryStrategy {
    case none
    case immediate(maxAttempts: Int)
    case exponentialBackoff(maxAttempts: Int, baseDelay: TimeInterval)
    case custom((Int) async -> TimeInterval?)
}

@MainActor
final class RetryManager {
    private var attemptCount = 0
    
    func executeWithRetry<T>(
        strategy: RetryStrategy,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        attemptCount = 0
        
        while true {
            do {
                let result = try await operation()
                attemptCount = 0 // 성공시 카운트 리셋
                return result
            } catch {
                attemptCount += 1
                
                let delay = await delayForStrategy(strategy, attempt: attemptCount)
                
                if let delay = delay {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                } else {
                    throw error
                }
            }
        }
    }
    
    private func delayForStrategy(_ strategy: RetryStrategy, attempt: Int) async -> TimeInterval? {
        switch strategy {
        case .none:
            return nil
            
        case .immediate(let maxAttempts):
            return attempt < maxAttempts ? 0 : nil
            
        case .exponentialBackoff(let maxAttempts, let baseDelay):
            if attempt < maxAttempts {
                return baseDelay * pow(2.0, Double(attempt - 1))
            }
            return nil
            
        case .custom(let delayCalculator):
            return await delayCalculator(attempt)
        }
    }
}

// MARK: - 상태 변화 로깅 (디버깅용)
struct StateChangeLogger<State: Equatable> {
    private let label: String
    
    init(label: String) {
        self.label = label
    }
    
    func log(from oldState: State, to newState: State) {
        #if DEBUG
        if oldState != newState {
            print("🔄 [\(label)] State Changed:")
            print("   From: \(oldState)")
            print("   To: \(newState)")
        }
        #endif
    }
}

// MARK: - Performance 측정
struct PerformanceTracker {
    private let startTime: CFAbsoluteTime
    private let operation: String
    
    init(operation: String) {
        self.operation = operation
        self.startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func end() -> TimeInterval {
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        #if DEBUG
        print("⏱️ [\(operation)] completed in \(String(format: "%.3f", timeElapsed))s")
        #endif
        
        return timeElapsed
    }
}

// MARK: - SwiftUI 확장
extension View {
    func trackPerformance(operation: String) -> some View {
        self.onAppear {
            _ = PerformanceTracker(operation: "\(operation) - onAppear")
        }
    }
    
    // 추천: 모든 Error 타입에 대해 작동하는 범용 버전
    func handleAsyncError<T: Error>(
        _ error: Binding<T?>,
        handler: @escaping (T) -> Void
    ) -> some View {
        self.background(
            ErrorWatcher(error: error, action: handler)
        )
    }
    
    // Equatable Error 타입을 위한 최적화된 버전 (직접적인 onChange 사용)
    func handleEquatableError<T>(
        error: Binding<T?>,
        handler: @escaping (T) -> Void
    ) -> some View where T: Error & Equatable {
        self.onChange(of: error.wrappedValue) { newError in
            if let newError = newError {
                handler(newError)
                error.wrappedValue = nil
            }
        }
    }
    
    // 가장 간단하고 실용적인 버전
    func onErrorChange<T: Error>(
        _ error: Binding<T?>,
        perform action: @escaping (T) -> Void
    ) -> some View {
        self.background(
            ErrorWatcher(error: error, action: action)
        )
    }
}

// MARK: - Error Watcher (에러 감시 유틸리티)
private struct ErrorWatcher<T: Error>: View {
    @Binding var error: T?
    let action: (T) -> Void
    
    var body: some View {
        Color.clear
            .onChange(of: error != nil) { hasError in
                if hasError, let currentError = error {
                    action(currentError)
                    error = nil
                }
            }
    }
}



// MARK: - 네트워크 상태 모니터링

@MainActor
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .unknown
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = self?.getConnectionType(from: path) ?? .unknown
            }
        }
        
        monitor.start(queue: queue)
    }
    
    private func getConnectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }
    
    deinit {
        monitor.cancel()
    }
}
