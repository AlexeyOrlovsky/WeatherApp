//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Алексей Орловский on 02.10.2023.
//

import Foundation
import RealmSwift

class WeatherDataRealm: Object {
    @objc dynamic var currentTemperature = 0.0
    @objc dynamic var maxTemperatureToday = 0.0
    @objc dynamic var minTemperatureToday = 0.0
    @objc dynamic var tomorrowTemperature = 0.0
    @objc dynamic var dayAfterTomorrowTemperature = 0.0
    @objc dynamic var cityName = ""
}
