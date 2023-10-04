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
    let countryWeatherLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    let weatherView: UIView = {
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
    
    let maxTemperatureView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    let maxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    
    let minTemperatureView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    let minTemperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    
    let tomorrowMaxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "Max".localized()
        label.textColor = .systemGray2
        label.font = .systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    
    let tomorrowLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    
    let dayAfterTMaxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "Max".localized()
        label.textColor = .systemGray2
        label.font = .systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    
    let dayAfterTomorrowLabel: UILabel = {
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
        view.addSubview(countryWeatherLabel)
        
        view.addSubview(weatherView)
        weatherView.addSubview(currentTemperatureLabel)
        
        view.addSubview(maxTemperatureView)
        maxTemperatureView.addSubview(maxTemperatureLabel)
        
        view.addSubview(minTemperatureView)
        minTemperatureView.addSubview(minTemperatureLabel)
        
        view.addSubview(tomorrowMaxTemperatureLabel)
        view.addSubview(tomorrowLabel)
        
        view.addSubview(dayAfterTMaxTemperatureLabel)
        view.addSubview(dayAfterTomorrowLabel)
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.showsBackgroundLocationIndicator = true
        
        locationManager?.requestWhenInUseAuthorization()
        
        requestLocationUpdate()
        
        if !Reachability.isConnectedToNetwork() {
            // Если нет интернета, загрузить данные из Realm
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
        self.countryWeatherLabel.text = weatherData.cityName
        let maxTemperatureLabelText = "H".localized() + ": \(weatherData.maxTemperatureToday)°C"
        self.maxTemperatureLabel.text = maxTemperatureLabelText
        let minTemperatureLabelText = "L".localized() + ": \(weatherData.minTemperatureToday)°C"
        self.minTemperatureLabel.text = minTemperatureLabelText
        let tomorrowLabelText = "Tomorrow".localized() + ": \(weatherData.tomorrowTemperature)°C"
        self.tomorrowLabel.text = tomorrowLabelText
        let dayAfterTomorrowLabelText = "DayAfterTomorrow".localized() + ": \(weatherData.dayAfterTomorrowTemperature)°C"
        self.dayAfterTomorrowLabel.text = dayAfterTomorrowLabelText
    }
    
    private func setupReachability() {
            reachabilityManager = NetworkReachabilityManager()
            reachabilityManager?.startListening { [weak self] status in
                switch status {
                case .reachable(_), .unknown:
                    print("Сеть доступна или неизвестное состояние.")
                    self?.handleNetworkStatusChange()
                case .notReachable:
                    print("Сеть недоступна.")
                }
            }
        }

    private func handleNetworkStatusChange() {
        // В этой функции вы можете добавить код для обновления данных и интерфейса,
        if Reachability.isConnectedToNetwork() {
            locationManager?.startUpdatingLocation()
        }
    }
    
    /// Constraints
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        countryWeatherLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(120)
        }
        
        weatherView.snp.makeConstraints { make in
            make.top.equalTo(countryWeatherLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        
        currentTemperatureLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(180)
        }
        
        maxTemperatureView.snp.makeConstraints { make in
            make.top.equalTo(weatherView.snp.bottom).offset(10)
            make.left.equalTo(weatherView.snp.left)
            make.width.equalTo(95)
            make.height.equalTo(40)
        }
        
        maxTemperatureLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        minTemperatureView.snp.makeConstraints { make in
            make.top.equalTo(weatherView.snp.bottom).offset(10)
            make.right.equalTo(weatherView.snp.right)
            make.width.equalTo(95)
            make.height.equalTo(40)
        }
        
        minTemperatureLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        tomorrowLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(50)
            make.left.equalToSuperview().inset(20)
        }
        
        tomorrowMaxTemperatureLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.bottom.equalTo(tomorrowLabel.snp.top)
        }
        
        dayAfterTomorrowLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(50)
            make.right.equalToSuperview().inset(20)
        }
        
        dayAfterTMaxTemperatureLabel.snp.makeConstraints { make in
            make.left.equalTo(dayAfterTomorrowLabel.snp.left)
            make.bottom.equalTo(dayAfterTomorrowLabel.snp.top)
        }
    }
}

// MARK: CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // В этом методе необходимо только инициализировать locationManager и запросить разрешение
        
        switch manager.authorizationStatus {
        case .notDetermined:
            print("When user did not yet determined")
            // Если разрешение еще не определено, ничего не делаем
        case .restricted:
            print("Restricted by parental control")
            // Если разрешение ограничено, ничего не делаем
        case .denied:
            print("When user select option Dont't Allow")
            // Пользователь запретил разрешение, начнем показывать Alert
            showLocationPermissionDeniedAlert()
        case .authorizedAlways:
            print("When user select option Change to Always Allow")
            // Если разрешено всегда, ничего не делаем
        case .authorizedWhenInUse:
            print("When user select option Allow While Using App or Allow Once")
            // Если разрешено при использовании приложения, ничего не делаем
        default:
            print("default")
        }
    }

    func showLocationPermissionDeniedAlert() {
        let alert = UIAlertController(title: "Доступ к геоданным отключен", message: "Вам нужно дать доступ к геоданным, чтобы мы могли показать вам погоду в вашем городе.", preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Разрешить", style: .default) { (_) in
            // Откройте настройки приложения для изменения разрешений
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }

        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
            // Закройте приложение
            exit(0)
        }

        alert.addAction(settingsAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)

        // Добавьте задержку и повторите проверку разрешения через некоторое время
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.locationManager?.requestWhenInUseAuthorization()
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
            // Разрешено использование геопозиции, выполните действия, связанные с получением погоды
            // и т.д.
            break // Добавьте оператор break, чтобы избежать ошибки компиляции
        case .denied:
            // Геолокация запрещена, покажите Alert
            showLocationPermissionDeniedAlert()
        default:
            break
        }
    }
}

