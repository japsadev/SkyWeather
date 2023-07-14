//
//  ThirdViewController.swift
//  iWeather
//
//  Created by Salih Yusuf Göktaş on 4.07.2023.
//

import UIKit
import MapKit
import CoreLocation

class ThirdViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

	let map = MKMapView()
	let locationManager = CLLocationManager()
	var weatherData: WeatherData?
	var customPins: [MKPointAnnotation] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(map)
		map.frame = view.bounds
		map.delegate = self
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
		
		let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
		   map.addGestureRecognizer(longPressGesture)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		locationManager.startUpdatingLocation()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		locationManager.stopUpdatingLocation()
	}

	
	@objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
			if gestureRecognizer.state == .began {
				let touchPoint = gestureRecognizer.location(in: map)
				let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
				addCustomPin(with: coordinate)
				fetchWeatherDataWithLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
			}
		}


	func addCustomPin(with coordinate: CLLocationCoordinate2D) {
			let pin = MKPointAnnotation()
			pin.coordinate = coordinate
			map.addAnnotation(pin)

			// Oluşturulan pin'i dizimize ekleyin
			customPins.append(pin)
		}
	
	func updateAllPins() {
		  // Elle eklenen tüm pinleri döngü ile kontrol ederek güncelleyin
		  for customPin in customPins {
			  let latitude = customPin.coordinate.latitude
			  let longitude = customPin.coordinate.longitude

			  // Hava durumu verilerini konum bilgisine göre yeniden alın
			  fetchWeatherDataWithLocation(latitude: latitude, longitude: longitude)
		  }
	  }

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard !(annotation is MKUserLocation) else {
			return nil
		}

		var annotationView = map.dequeueReusableAnnotationView(withIdentifier: "custom")

		if annotationView == nil {
			// Create the view
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
			annotationView?.canShowCallout = true
		} else {
			annotationView?.annotation = annotation
		}
		annotationView?.image = UIImage(named: "CloudsPin")
		return annotationView
	}

}

// CLLocationManagerDelegate için ek fonksiyonlar burada uzantı içinde tanımlanır.
extension ThirdViewController {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.last {
			// Konum bilgisine ulaşabilirsiniz, örneğin location.coordinate.latitude ve location.coordinate.longitude ile enlem ve boylamı alabilirsiniz.
			// Bu konum bilgisini API çağrısında kullanarak hava durumu verisini alabilirsiniz.
			// API çağrısını yapmak için kullanıcının konumu güncellendiğinde bu fonksiyonu kullanabilirsiniz.
			fetchWeatherDataWithLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

			// Konum verileri alındı, şimdi harita üzerindeki pini güncelleyelim.
			addCustomPin(with: location.coordinate)
		}
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		// Konum bilgisini alırken bir hata oluştu.
		// Hata durumunu yönetmek için burada uygun işlemleri gerçekleştirebilirsiniz.
	}

	func fetchWeatherDataWithLocation(latitude: Double, longitude: Double) {
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

						// Konum verileri alındı, şimdi harita üzerindeki pini güncelleyelim.
						DispatchQueue.main.async {
							if let annotation = self.map.annotations.first(where: { $0.coordinate.latitude == latitude && $0.coordinate.longitude == longitude }) as? MKPointAnnotation {
								self.updatePin(with: weatherData, for: annotation)
							}
						}
					} catch {
						print("Error decoding weather data: \(error)")
					}
				}
			}.resume()
		}
	}


	func updatePin(with weatherData: WeatherData, for annotation: MKPointAnnotation) {
			// Güncel hava durumu verileri ile pin'i güncelleyin
			let temperature = Int(weatherData.main.temp)
			let weatherType = weatherData.weather.first?.main.capitalized ?? ""
			annotation.title = "\(temperature)°"
			annotation.subtitle = weatherType

			// Hava durumu durumlarına göre uygun görsel adını belirleyin
			var imageName = "CloudsPin" // Varsayılan görsel adı
			switch weatherType {
				case "Clouds":
					imageName = "CloudsPin"
				case "Clear":
					imageName = "ClearPin"
				case "Rain":
					imageName = "RainPin"
				case "Snow":
					imageName = "SnowPin"
				case "Thunderstorm":
					imageName = "ThunderstormPin"
				// Daha fazla hava durumu durumu eklemek için case blokları oluşturun
				default:
					break
			}

			// Görseli yüklemek için UIImage nesnesini oluştur ve görseli atama
			let annotationView = map.view(for: annotation)
			annotationView?.image = UIImage(named: imageName)
		}
}

