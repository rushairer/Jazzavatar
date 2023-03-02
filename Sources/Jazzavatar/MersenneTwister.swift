//
//  MersenneTwister.swift
//  
//
//  Created by Abenx on 2023/3/2.
//

import Foundation

public struct MersenneTwister {
    private static let n: Int = 624
    private static let m: Int = 397
    private static let matrixA: UInt32 = 0x9908b0df
    private static let upperMask: UInt32 = 0x80000000
    private static let lowerMask: UInt32 = 0x7fffffff
    private static let DefaultSeed = 5489
    
    var mti: Int
    var mt: [UInt32] = Array(repeating: 0, count: Self.n)
    var mag01: [UInt32] = [0x0, Self.matrixA]
    
    public init(seed: UInt32) {
        mt = Array(self.mt[...])
        mt[0] = seed
        for i in 1..<Self.n {
            let n = mt[i-1]
            let m = n >> 30
            let p = n ^ m
            let r = 1812433253 &* p &+ UInt32(i)
            mt[i] = UInt32(r)
        }
        mti = Self.n
    }
    
    public mutating func nextReal1() -> Double {
        return Double(next()) * ( 1.0 / 4294967295.0)
    }
    
    public mutating func nextReal2() -> Double {
        return Double(next()) * ( 1.0 / 4294967296.0)
    }
    
    public mutating func nextReal3() -> Double {
        return (Double(next()) + 0.5) * ( 1.0 / 4294967296.0)
    }
    
    public mutating func next() -> UInt32 {
        var y: UInt32
        
        if mti >= Self.n {
            var okk: Int = 0
            var mt = Array(self.mt[...])
            
            for kk in 0..<(Self.n - Self.m) {
                y = (mt[kk] & Self.upperMask) | (mt[kk+1] & Self.lowerMask)
                mt[kk] = mt[kk + Self.m] ^ (y >> 1) ^ mag01[Int(y)&0x1]
                
                okk = kk + 1
            }

            for kk in okk..<(Self.n-1) {
                y = (mt[kk] & Self.upperMask) | (mt[kk+1] & Self.lowerMask)
                mt[kk] = mt[kk + Self.m - Self.n] ^ (y >> 1) ^ mag01[Int(y)&0x1]
            }
            
            y = (mt[Self.n-1] & Self.upperMask) | (mt[0] & Self.lowerMask)
            mt[Self.n-1] = mt[Self.m-1] ^ (y >> 1) ^ mag01[Int(y)&0x1]
            mti = 0
            
            self.mt = mt
        }
        
        y = self.mt[mti]

        mti = self.mti + 1

        y ^= y >> 11
        y ^= (y << 7) & 0x9d2c5680
        y ^= (y << 15) & 0xefc60000
        y ^= y >> 18
        
        return y
    }
}
