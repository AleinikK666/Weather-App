//
//  WeatherVC.swift
//  Weather
//
//  Created by Екатерина Алейник on 11.05.25.
//

import UIKit
import CoreLocation

private struct LayoutConstants {
    static let buttonSize = CGFloat(50)
    static let conditionImageSize = CGFloat(150)
    static let temperatureFontSize = CGFloat(90)
    static let cityFontSize = CGFloat(45)
    static let horizontalPadding = CGFloat(30)
    static let searchSpacing = CGFloat(12)
    static let weatherSpacing = CGFloat(30)
    static let searchTopPadding = CGFloat(20)
}

class WeatherVC: UIViewController {
    var weatherService = WeatherService()
    let locationManager = CLLocationManager()
    
    // Search
    let searchStackView = UIStackView()
    let locationButton = UIButton()
    let searchTextField = UITextField()
    let searchButton = UIButton()
    
    // Weather 
    let weatherStackView = UIStackView()
    let conditionImageView = UIImageView()
    let temperatureLabel = UILabel()
    let cityLabel = UILabel()
    
    let backgroundView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        style()
        layout()
    }
    
    private func setup() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        searchTextField.delegate = self
        weatherService.delegate = self
    }
    
    private func style() {
        // Search Stack
        searchStackView.axis = .horizontal
        searchStackView.spacing = LayoutConstants.searchSpacing
        searchStackView.alignment = .center
        
        locationButton.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        locationButton.tintColor = .label
        locationButton.addTarget(self, action: #selector(locationPressed), for: .touchUpInside)
        
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.tintColor = .label
        searchButton.addTarget(self, action: #selector(searchPressed), for: .touchUpInside)
        
        searchTextField.placeholder = "Search"
        searchTextField.textAlignment = .left
        searchTextField.borderStyle = .roundedRect
        searchTextField.backgroundColor = .systemFill
        searchTextField.font = .systemFont(ofSize: 20)
        
        // Weather Stack
        weatherStackView.axis = .vertical
        weatherStackView.spacing = LayoutConstants.weatherSpacing
        weatherStackView.alignment = .center
        
        conditionImageView.tintColor = .label
        conditionImageView.contentMode = .scaleAspectFit
        
        temperatureLabel.font = UIFont.systemFont(ofSize: LayoutConstants.temperatureFontSize, weight: .bold)
        temperatureLabel.textAlignment = .center
        
        cityLabel.font = UIFont.systemFont(ofSize: LayoutConstants.cityFontSize)
        cityLabel.textAlignment = .center
        
        backgroundView.image = UIImage(named: "background")
        backgroundView.contentMode = .scaleAspectFill
    }
    
    private func layout() {
        view.addSubview(backgroundView)
        view.addSubview(searchStackView)
        view.addSubview(weatherStackView)
        
        // Добавляем элементы в search stack
        searchStackView.addArrangedSubview(locationButton)
        searchStackView.addArrangedSubview(searchTextField)
        searchStackView.addArrangedSubview(searchButton)
        
        // Добавляем элементы в weather stack
        weatherStackView.addArrangedSubview(conditionImageView)
        weatherStackView.addArrangedSubview(temperatureLabel)
        weatherStackView.addArrangedSubview(cityLabel)
        
        // Настройка constraints
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        searchStackView.translatesAutoresizingMaskIntoConstraints = false
        weatherStackView.translatesAutoresizingMaskIntoConstraints = false
        conditionImageView.translatesAutoresizingMaskIntoConstraints = false
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Background
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Search Stack (фиксируется вверху)
            searchStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LayoutConstants.searchTopPadding),
            searchStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstants.horizontalPadding),
            searchStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstants.horizontalPadding),
            
            // Weather Stack (центрируется)
            weatherStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Фиксированные размеры
            conditionImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.conditionImageSize),
            conditionImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.conditionImageSize),
            
            locationButton.widthAnchor.constraint(equalToConstant: LayoutConstants.buttonSize),
            locationButton.heightAnchor.constraint(equalToConstant: LayoutConstants.buttonSize),
            
            searchButton.widthAnchor.constraint(equalToConstant: LayoutConstants.buttonSize),
            searchButton.heightAnchor.constraint(equalToConstant: LayoutConstants.buttonSize),
            
            // Ширина search stack
            searchStackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -2*LayoutConstants.horizontalPadding)
        ])
    }
    
    @objc func locationPressed() {
        locationManager.requestLocation()
    }
    
    @objc func searchPressed() {
        searchTextField.endEditing(true)
    }
}

// Остальные extension остаются без изменений
extension WeatherVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            weatherService.fetchWeather(cityName: city)
        }
        searchTextField.text = ""
    }
}

extension WeatherVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherService.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension WeatherVC: WeatherServiceDelegate {
    func didFetchWeather(_ weatherService: WeatherService, _ weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.cityLabel.text = weather.cityName
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
        }
    }
    
    func didFailWithError(_ weatherService: WeatherService, _ error: ServiceError) {
        print(error)
    }
}
