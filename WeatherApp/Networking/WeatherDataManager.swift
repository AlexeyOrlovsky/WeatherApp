//
//  DataRequestWeather.swift
//  WeatherApp
//
//  Created by Алексей Орловский on 03.10.2023.
//

import RealmSwift
import Alamofire
import os

class WeatherDataManager {
    static let shared = WeatherDataManager()
    
    private let baseUrl = "http://api.weatherapi.com/v1"
    private let forecastEndpoint = "/forecast.json"
    private let apiKey = "446e407a04b9438eaa6122505230210"

    // Метод для сохранения данных в Realm
    func saveWeatherData(weatherData: WeatherDataRealm) {
        do {
            let realm = try Realm()
            
            if let existingWeatherData = realm.objects(WeatherDataRealm.self).filter("cityName == %@", weatherData.cityName).first {
                try realm.write {
                    // Если запись существует, обновить данными из сети
                    existingWeatherData.currentTemperature = weatherData.currentTemperature
                    existingWeatherData.maxTemperatureToday = weatherData.maxTemperatureToday
                    existingWeatherData.minTemperatureToday = weatherData.minTemperatureToday
                    existingWeatherData.tomorrowTemperature = weatherData.tomorrowTemperature
                    existingWeatherData.dayAfterTomorrowTemperature = weatherData.dayAfterTomorrowTemperature
                }
            } else {
                try realm.write {
                    realm.add(weatherData)
                }
            }
            
            let oldWeatherData = realm.objects(WeatherDataRealm.self).filter("cityName != %@", weatherData.cityName)
            try realm.write {
                realm.delete(oldWeatherData)
            }
        } catch {
            os_log("Error saving weather data: %@", log: OSLog.default, type: .error, error.localizedDescription)
        }
    }

    func loadWeatherData() -> WeatherDataRealm? {
        let realm = try! Realm()
        return realm.objects(WeatherDataRealm.self).first
    }

    func fetchWeather(latitude: Double, longitude: Double, completionHandler: @escaping (Result<WeatherDataRealm, Error>) -> Void) {
        let parameters: Parameters = ["key": apiKey, "q": "\(latitude),\(longitude)", "days": 3]

        AF.request(baseUrl + forecastEndpoint, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any], let weatherData = self.parseWeatherData(json: json) {
                    completionHandler(.success(weatherData))
                } else {
                    completionHandler(.failure(NSError(domain: "WeatherApp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    private func parseWeatherData(json: [String: Any]) -> WeatherDataRealm? {
        guard let current = json["current"] as? [String: Any],
              let currentTemperature = current["temp_c"] as? Double,
              let location = json["location"] as? [String: Any],
              let cityName = location["name"] as? String else {
            return nil
        }

        var weatherData = WeatherDataRealm()
        weatherData.cityName = cityName
        weatherData.currentTemperature = currentTemperature

        if let forecast = json["forecast"] as? [String: Any],
           let forecastDays = forecast["forecastday"] as? [[String: Any]],
           forecastDays.count >= 3 {
            if let todayDay = forecastDays.first,
               let dayTemperature = todayDay["day"] as? [String: Any],
               let maxTempToday = dayTemperature["maxtemp_c"] as? Double,
               let minTempToday = dayTemperature["mintemp_c"] as? Double {
                weatherData.maxTemperatureToday = maxTempToday
                weatherData.minTemperatureToday = minTempToday
            }

            if let tomorrowDay = forecastDays[1] as? [String: Any],
               let dayTemperature = tomorrowDay["day"] as? [String: Any],
               let maxTemp = dayTemperature["maxtemp_c"] as? Double {
                weatherData.tomorrowTemperature = maxTemp
            }

            if let dayAfterTomorrowDay = forecastDays[2] as? [String: Any],
               let dayTemperature = dayAfterTomorrowDay["day"] as? [String: Any],
               let maxTemp = dayTemperature["maxtemp_c"] as? Double {
                weatherData.dayAfterTomorrowTemperature = maxTemp
            }
        }
        return weatherData
    }
    
    static func isConnectedToNetwork() -> Bool {
        return Reachability.isConnectedToNetwork()
    }
}
