//
//  MediumExample.swift
//  JSMacroChart
//
//  Created by yangjs on 7/23/25.
//

class Model01 {
    func heavyComputationCaller () async {
        let _ = await heavyComputation()
    }
    func heavyComputation() async -> Int {
        /* John thread */
        var result = 0
        
         for i in 1...100_000 {
             let temp = i % 1000
             result = (result + temp * temp) % Int.max
             
             var n = i % 1000 + 1
             var steps = 0
             while n != 1 && steps < 100 {
                 if n % 2 == 0 {
                     n = n / 2
                 } else {
                     n = n * 3 + 1
                 }
                 steps += 1
             }
             result = (result + steps) % Int.max
         }
         
         var numbers = Array(1...5_000).shuffled()
         for i in 0..<min(numbers.count, 1000) {
             for j in 0..<(min(numbers.count, 1000) - i - 1) {
                 if numbers[j] > numbers[j + 1] {
                     numbers.swapAt(j, j + 1)
                 }
             }
         }
        /* John thread */
         return result % Int.max
    }
}
