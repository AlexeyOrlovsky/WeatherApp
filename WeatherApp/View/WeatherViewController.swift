//
//  ViewController.swift
//  WeatherApp
//
//  Created by Алексей Орловский on 02.10.2023.
//

import UIKit
import SnapKit
import Alamofire
import RealmSwift
import CoreLocation
import Reachability

class WeatherViewController: UIViewController {
    
    var locationManager: CLLocationManager?
    private var reachabilityManager: NetworkReachabilityManager?
    
    /// UI Elements
    let currentCityNamelabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    let temperatureView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        return view
    }()
    
    let currentTemperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "Location permission required".localized()
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()
    
    let maxTemperatureTodayView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    let maxTemperatureTodayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    
    let minTemperatureTodayView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    let minTemperatureTodayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    
    let maxTemperatureTomorrowLabel: UILabel = {
        let label = UILabel()
        label.text = "Max".localized()
        label.textColor = .systemGray2
        label.font = .systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    
    let tomorrowTemperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    
    let maxTemperatureDayAfterTomLabel: UILabel = {
        let label = UILabel()
        label.text = "Max".localized()
        label.textColor = .systemGray2
        label.font = .systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    
    let dayAfterTomorrowTemperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewDidLoad()
        setupAddSubviews()
        setupLocationManager()
        
        setupReachability()
    }
    
    func setupViewDidLoad() {
        view.backgroundColor = .systemBackground
    }
    
    func setupAddSubviews() {
        view.addSubview(currentCityNamelabel)
        
        view.addSubview(temperatureView)
        temperatureView.addSubview(currentTemperatureLabel)
        
        view.addSubview(maxTemperatureTodayView)
        maxTemperatureTodayView.addSubview(maxTemperatureTodayLabel)
        
        view.addSubview(minTemperatureTodayView)
        minTemperatureTodayView.addSubview(minTemperatureTodayLabel)
        
        view.addSubview(maxTemperatureTomorrowLabel)
        view.addSubview(tomorrowTemperatureLabel)
        
        view.addSubview(maxTemperatureDayAfterTomLabel)
        view.addSubview(dayAfterTomorrowTemperatureLabel)
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.showsBackgroundLocationIndicator = true
        
        locationManager?.requestWhenInUseAuthorization()
        
        requestLocationUpdate()
        
        if !Reachability.isConnectedToNetwork() {
            /// If not data from network, upload data from Realm
            if let loadedWeatherData = WeatherDataManager.shared.loadWeatherData() {
                updateUI(with: loadedWeatherData)
            }
        }
    }
    
    private func requestLocationUpdate() {
        locationManager?.startUpdatingLocation()
    }
    
    private func stopLocationUpdate() {
        locationManager?.stopUpdatingLocation()
    }
    
    func updateUI(with weatherData: WeatherDataRealm) {
        self.currentTemperatureLabel.text = "\(weatherData.currentTemperature)°C"
        self.currentCityNamelabel.text = weatherData.cityName
        let maxTemperatureLabelText = "H".localized() + ": \(weatherData.maxTemperatureToday)°C"
        self.maxTemperatureTodayLabel.text = maxTemperatureLabelText
        let minTemperatureLabelText = "L".localized() + ": \(weatherData.minTemperatureToday)°C"
        self.minTemperatureTodayLabel.text = minTemperatureLabelText
        let tomorrowLabelText = "Tomorrow".localized() + ": \(weatherData.tomorrowTemperature)°C"
        self.tomorrowTemperatureLabel.text = tomorrowLabelText
        let dayAfterTomorrowLabelText = "DayAfterTomorrow".localized() + ": \(weatherData.dayAfterTomorrowTemperature)°C"
        self.dayAfterTomorrowTemperatureLabel.text = dayAfterTomorrowLabelText
    }
    
    private func setupReachability() {
            reachabilityManager = NetworkReachabilityManager()
            reachabilityManager?.startListening { [weak self] status in
                switch status {
                case .reachable(_), .unknown:
                    print("Network available")
                    self?.handleNetworkStatusChange()
                case .notReachable:
                    print("Network unavailable")
                }
            }
        }

    private func handleNetworkStatusChange() {
        /// Update data and interface
        if Reachability.isConnectedToNetwork() {
            locationManager?.startUpdatingLocation()
        }
    }
    
    /// Constraints
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        currentCityNamelabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(120)
        }
        
        temperatureView.snp.makeConstraints { make in
            make.top.equalTo(currentCityNamelabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        
        currentTemperatureLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(180)
        }
        
        maxTemperatureTodayView.snp.makeConstraints { make in
            make.top.equalTo(temperatureView.snp.bottom).offset(10)
            make.left.equalTo(temperatureView.snp.left)
            make.width.equalTo(95)
            make.height.equalTo(40)
        }
        
        maxTemperatureTodayLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        minTemperatureTodayView.snp.makeConstraints { make in
            make.top.equalTo(temperatureView.snp.bottom).offset(10)
            make.right.equalTo(temperatureView.snp.right)
            make.width.equalTo(95)
            make.height.equalTo(40)
        }
        
        minTemperatureTodayLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        tomorrowTemperatureLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(50)
            make.left.equalToSuperview().inset(20)
        }
        
        maxTemperatureTomorrowLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.bottom.equalTo(tomorrowTemperatureLabel.snp.top)
        }
        
        dayAfterTomorrowTemperatureLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(50)
            make.right.equalToSuperview().inset(20)
        }
        
        maxTemperatureDayAfterTomLabel.snp.makeConstraints { make in
            make.left.equalTo(dayAfterTomorrowTemperatureLabel.snp.left)
            make.bottom.equalTo(dayAfterTomorrowTemperatureLabel.snp.top)
        }
    }
}

// MARK: CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        /// Init locationManager and request permission
        
        switch manager.authorizationStatus {
        case .notDetermined:
            print("When user did not yet determined")
        case .restricted:
            print("Restricted by parental control")
        case .denied:
            print("When user select option Dont't Allow")
            showLocationPermissionDeniedAlert()
        case .authorizedAlways:
            print("When user select option Change to Always Allow")
        case .authorizedWhenInUse:
            print("When user select option Allow While Using App or Allow Once")
        default:
            print("default")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
        
        WeatherDataManager.shared.fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { result in
            switch result {
            case .success(let weatherData):
                WeatherDataManager.shared.saveWeatherData(weatherData: weatherData)
                DispatchQueue.main.async {
                    self.updateUI(with: weatherData)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            /// Allowed to use geolocation, perform actions related to getting weather
            break /// break statement to avoid compilation error
        case .denied:
            /// Geolocation  prohibited, show Alert
            showLocationPermissionDeniedAlert()
        default:
            break
        }
    }
}

/// Alerts
extension WeatherViewController {
    
    func showLocationPermissionDeniedAlert() {
        let alert = UIAlertController(title: "Access disabled".localized(), message: "provide access to geodata".localized(), preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Allow".localized(), style: .default) { (_) in
            /// Open settings to change permissions
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive) { (_) in
            /// сlose app
            exit(0)
        }

        alert.addAction(cancelAction)
        alert.addAction(settingsAction)

        present(alert, animated: true, completion: nil)

        /// delay and check permission after some time
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.locationManager?.requestWhenInUseAuthorization()
        }
    }
}

