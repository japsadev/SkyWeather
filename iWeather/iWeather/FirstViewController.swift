//
//  FirstViewController.swift
//  iWeather
//
//  Created by Salih Yusuf Göktaş on 3.07.2023.
//

import UIKit
import CoreLocation


class FirstViewController: UIViewController, CLLocationManagerDelegate {
	
	// MARK: - IBOutlets
	
	@IBOutlet weak var searchTextField: UITextField!
	@IBOutlet weak var searchButton: UIButton!
	@IBOutlet weak var cityNameLabel: UILabel!
	@IBOutlet weak var weatherImageView: UIImageView!
	@IBOutlet weak var weatherLabel: UILabel!
	@IBOutlet weak var weatherTypeLabel: UILabel!
	@IBOutlet weak var windLabel: UILabel!
	@IBOutlet weak var humidityLabel: UILabel!
	@IBOutlet weak var rainLabel: UILabel!
	@IBOutlet weak var viewBackground: UIView!
	
	// MARK: - Properties
	
	let locationManager = CLLocationManager()

	
	// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		viewBackground.layer.masksToBounds = false
				viewBackground.layer.cornerRadius = 40
				viewBackground.clipsToBounds = true
				
				let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeTheKeyboard))
				view.addGestureRecognizer(gestureRecognizer)
				
				// Request location permission
				locationManager.delegate = self
				locationManager.requestWhenInUseAuthorization()
			}
			
			@objc func closeTheKeyboard() {
				view.endEditing(true)
			}

	// MARK: - IBActions
	
	@IBAction func searchButtonTapped(_ sender: UIButton) {
		
		let city = searchTextField.text ?? ""
		
		if city.isEmpty {
			
			let alert = UIAlertController(title: "WARNING!", message: "Please enter city name.", preferredStyle: .alert)
			
			let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			
			alert.addAction(cancelButton)
			
			self.present(alert, animated: true, completion: nil)
			
		}else{
			
			if let cityName = searchTextField.text {
				fetchWeatherData(with: cityName)
			}
		}
	}

	// MARK: - Helper Functions
	
	func fetchWeatherData(with cityName: String) {
		let apiKey = "07fdaa7b7fa8a2befa831458fcdd3ed9"
		let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
		let urlString = "\(baseUrl)?q=\(cityName)&appid=\(apiKey)&units=metric"
		
		if let url = URL(string: urlString) {
			URLSession.shared.dataTask(with: url) { data, response, error in
				if let data = data {
					do {
						let decoder = JSONDecoder()
						decoder.keyDecodingStrategy = .convertFromSnakeCase
						let weatherData = try decoder.decode(WeatherData.self, from: data)
						
						// Update UI with weather data
						self.updateUI(with: weatherData)
					} catch {
						print("Error decoding weather data: \(error)")
					}
				}
			}.resume()
		}
	}
	
	// MARK: - CLLocationManagerDelegate
	
	
	
	override func viewDidAppear(_ animated: Bool) {
		
		//Animations
		
		UIView.animate(withDuration: 1, animations:  {
			self.viewBackground.transform = CGAffineTransform(translationX: 0, y: -30)
			
		}, completion: nil)
		
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Start updating location when the view will appear
		locationManager.startUpdatingLocation()
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.last {
			// Stop updating location to avoid unnecessary calls
			locationManager.stopUpdatingLocation()
			
			// Fetch weather data with user's location coordinates
			fetchWeatherDataWithLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Error fetching location: \(error.localizedDescription)")
	}
	
	// MARK: - Private Helper Functions
	
	private func fetchWeatherDataWithLocation(latitude: Double, longitude: Double) {
		let apiKey = "07fdaa7b7fa8a2befa831458fcdd3ed9"
		let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
		let urlString = "\(baseUrl)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
		
		if let url = URL(string: urlString) {
			URLSession.shared.dataTask(with: url) { data, response, error in
				if let data = data {
					do {
						let decoder = JSONDecoder()
						decoder.keyDecodingStrategy = .convertFromSnakeCase
						let weatherData = try decoder.decode(WeatherData.self, from: data)
						
						// Update UI with weather data
						self.updateUI(with: weatherData)
					} catch {
						print("Error decoding weather data: \(error)")
					}
				}
			}.resume()
		}
	}
	
	func updateUI(with weatherData: WeatherData) {
		DispatchQueue.main.async {
			self.cityNameLabel.text = weatherData.name
			let temperature = Int(weatherData.main.temp)
			self.weatherLabel.text = "\(temperature) °C"
			self.weatherTypeLabel.text = weatherData.weather.first?.main.capitalized ?? ""
			self.windLabel.text = "\(weatherData.wind.speed) m/s"
			self.humidityLabel.text = "\(weatherData.main.humidity)%"
			
			if let rainVolume = weatherData.rain?.volume {
				self.rainLabel.text = "\(rainVolume) mm"
			} else {
				self.rainLabel.text = "N/A"
			}
			
			// Hava durumu açıklamasını al ve updateWeatherImage fonksiyonuna gönder
			let weatherDescription = weatherData.weather.first?.main ?? ""
			self.updateWeatherImage(with: weatherDescription)
		}
	}
	
	func updateWeatherImage(with weatherDescription: String) {
		print("updateWeatherImage with: \(weatherDescription)")
		var imageName = "Clouds" // Varsayılan görsel adı
		
		// Hava durumu durumlarına göre uygun görsel adını belirle
		switch weatherDescription.capitalized {
		case "Clouds":
			imageName = "Clouds"
		case "Clear":
			imageName = "Clear"
		case "Rain":
			imageName = "Rain"
		case "Snow":
			imageName = "Snow"
		case "Thunderstorm":
			imageName = "Thunderstorm"
		// Daha fazla hava durumu durumu eklemek için case blokları oluşturun
		default:
			break
		}
		
		print("Selected image name: \(imageName)")
		// Görseli yüklemek için UIImage nesnesini oluştur ve görseli atama
		if let image = UIImage(named: imageName) {
			self.weatherImageView.image = image
		} else {
			self.weatherImageView.image = UIImage(named: "default")
		}
	}
}

struct WeatherData: Codable {
	let name: String
	let main: Main
	let weather: [Weather]
	let wind: Wind
	let rain: Rain?
	
	enum CodingKeys: String, CodingKey {
		case name, main, weather, wind
		case rain = "1h"
	}
}

struct Main: Codable {
	let temp: Double
	let humidity: Int
}

struct Weather: Codable {
	let main: String
}

struct Wind: Codable {
	let speed: Double
}

struct Rain: Codable {
	let volume: Double?
	
	enum CodingKeys: String, CodingKey {
		case volume = "1h"
	}
}
