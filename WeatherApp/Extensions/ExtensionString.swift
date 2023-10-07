//
//  ExtensionString.swift
//  WeatherApp
//
//  Created by Алексей Орловский on 04.10.2023.
//

import Foundation

extension String {
    
    /// Method is used to localize the string
    func localized() -> String {
        
        /// NSLocalizedString - used for get localized strings in application
        NSLocalizedString( self,
                           tableName: "Localizable",
                           bundle: .main,
                           value: self,
                           comment: self
        )
        
        /// self - current string which need localisation
        /// tableName - localization file name
        /// bundle - the main application bundle is used (bundle - this is folder where files and resources application stored)
        /// value - default value
        /// comment - comment, explanation of what the line is for
    }
}
