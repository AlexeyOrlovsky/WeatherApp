//
//  DataRequestWeather.swift
//  WeatherApp
//
//  Created by Алексей Орловский on 03.10.2023.
//

import RealmSwift
import Alamofire
import os /// ecord events and errors in the log inside the application

/// WeatherDataManager provides methods for loading, saving and parsing weather data, as well as testing network connectivity
class WeatherDataManager {
    static let shared = WeatherDataManager()
    
    private let baseUrl = "http://api.weatherapi.com/v1"
    private let forecastEndpoint = "/forecast.json"
    private let apiKey = "446e407a04b9438eaa6122505230210"

    /// Save data in Realm base
    func saveWeatherData(weatherData: WeatherDataRealm) {
        
        /// do-catch for handling error
        do {
            let realm = try Realm() /// creating realm object
            
            /// checking for the existence of an entry in the realm with the specified city name
            if let existingWeatherData = realm.objects(WeatherDataRealm.self).filter("cityName == %@", weatherData.cityName).first {
                try realm.write {
                    /// If record exist, update data in base, data from network
                    existingWeatherData.currentTemperature = weatherData.currentTemperature
                    existingWeatherData.maxTemperatureToday = weatherData.maxTemperatureToday
                    existingWeatherData.minTemperatureToday = weatherData.minTemperatureToday
                    existingWeatherData.tomorrowTemperature = weatherData.tomorrowTemperature
                    existingWeatherData.dayAfterTomorrowTemperature = weatherData.dayAfterTomorrowTemperature
                }
            } else {
                /// If the entry does not exist, then a new entry is created in Realm
                try realm.write {
                    realm.add(weatherData)
                }
            }
            
            /// searches old weather data for other cities and removes from Realm base
            let oldWeatherData = realm.objects(WeatherDataRealm.self).filter("cityName != %@", weatherData.cityName)
            try realm.write {
                realm.delete(oldWeatherData)
            }
            /// If error occurs during the execution of any part of the code, it is processed in the catch block and recorded in the log using os_log
        } catch {
            /// thsi code writing error in magazine application
            /// OSLog.default - uses the default standard log, error.localizedDescription - error information
            os_log("Error saving weather data: %@", log: OSLog.default, type: .error, error.localizedDescription)
        }
    }

    /// this method upload data from realm and return first recording (if recording exist)
    func loadWeatherData() -> WeatherDataRealm? {
        let realm = try! Realm()
        /// returns the first record from the query result or nil
        return realm.objects(WeatherDataRealm.self).first
    }

    /// this method execute  request, after get data from server this method give result in Result WeatherDataRealm, Error style
    func fetchWeather(latitude: Double, longitude: Double, completionHandler: @escaping (Result<WeatherDataRealm, Error>) -> Void) {
        /// dictionary with query parameters | API Key, coordinates, number of days for forecast
        let parameters: Parameters = ["key": apiKey, "q": "\(latitude),\(longitude)", "days": 3]

        /// HTTP request to the weather API
        AF.request(baseUrl + forecastEndpoint, parameters: parameters).responseJSON { response in
            /// query results are processed
            switch response.result {
                
            /// data in the response is parsed
            case .success(let value):
                if let json = value as? [String: Any], let weatherData = self.parseWeatherData(json: json) {
                    /// if all is well, the completion handler is called
                    completionHandler(.success(weatherData))
                } else {
                    /// If the JSON is invalid or could not be parsed, the completion handler is called with an error
                    completionHandler(.failure(NSError(domain: "WeatherApp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])))
                }
                
            /// If the request fails (network error, etc.), the completion handler is called with an error
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }

    /// this method is parce data about weather fron JSON answer
    /// It retrieves the current temperature, city name, and forecasts for the coming days if available
    private func parseWeatherData(json: [String: Any]) -> WeatherDataRealm? {
        guard let current = json["current"] as? [String: Any],
              let currentTemperature = current["temp_c"] as? Double,
              let location = json["location"] as? [String: Any],
              let cityName = location["name"] as? String else {
            
            /// If any data is missing or cannot be retrieved, the function return nil
            return nil
        }

        var weatherData = WeatherDataRealm() /// create object type WeatherDataRealm
        
        /// weatherData properties are filled based on data from JSON
        weatherData.cityName = cityName
        weatherData.currentTemperature = currentTemperature

        /// checking the availability of forecast data
        /// If forecast data is available and includes forecasts for at least 3 days, then it retrieves additional data
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
        
        /// the function returns a WeatherDataRealm object that contains information
        /// about the current weather and forecasts, or nil if the data could not be retrieved from JSON
        return weatherData
    }
    
    /// This method checks if the device is connected to the internet
    /// For this using library Reachability which is used to determine network availability 
    /// used to decide whether to make a request to the server or use local data
    static func isConnectedToNetwork() -> Bool {
        return Reachability.isConnectedToNetwork()
    }
}
