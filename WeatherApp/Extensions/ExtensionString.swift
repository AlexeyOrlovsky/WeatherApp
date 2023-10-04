//
//  ExtensionString.swift
//  WeatherApp
//
//  Created by Алексей Орловский on 04.10.2023.
//

import Foundation

extension String {
    func localized() -> String {
        NSLocalizedString( self,
                           tableName: "Localizable",
                           bundle: .main,
                           value: self,
                           comment: self
        )
    }
}
