//
//  Reac.swift
//  WeatherApp
//
//  Created by Алексей Орловский on 03.10.2023.
//

import SystemConfiguration

public class Reachability {

    class func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired

        return isReachable && !needsConnection
    }
}


