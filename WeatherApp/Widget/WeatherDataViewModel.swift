//
//  WeatherDataViewModel.swift
//  WeatherApp
//
//  Created by Алексей Орловский on 04.10.2023.
//

import SwiftUI

class WeatherDataViewModel: ObservableObject {
    @Published var weatherData: WeatherDataRealm?

    func fetchWeatherData(latitude: Double, longitude: Double) {
        WeatherDataManager.shared.fetchWeather(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.weatherData = data
                }
            case .failure(let error):
                // Обработка ошибки
                print("Error fetching weather data: \(error)")
            }
        }
    }
}
