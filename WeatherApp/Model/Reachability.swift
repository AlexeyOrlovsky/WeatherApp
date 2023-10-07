//
//  Reac.swift
//  WeatherApp
//
//  Created by Алексей Орловский on 03.10.2023.
//

import SystemConfiguration /// checks network connection states

/// Reachability class, contains methods for checking connectivity
public class Reachability {

    /// checks if the device is connected to the network
    class func isConnectedToNetwork() -> Bool {

        /// Created structure be used for create SCNetworkReachabilityRef object representing for network connection
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        /// This code creates an SCNetworkReachabilityRef object using SCNetworkReachabilityCreateWithAddress
        /// This object provides network connection information for a given address
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            
            /// If object creation fails, the function will return false
            return false
        }
        
        /// The flags variable is created, which will contain the network connection flags
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags == .reachable /// Device conected to the network
        let needsConnection = flags == .connectionRequired /// Connection required to connect

        /// If the device is connected to the network
        return isReachable && !needsConnection
    }
}


