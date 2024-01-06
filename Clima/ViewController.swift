//
//  ViewController.swift
//  Clima
//
//  Created by 岡村武流 on 2024/01/05.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,UITextFieldDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    var inputLocation: String = ""
    var displayWeather: String = ""
    var tem:Double = 0.0
    var location:String = ""
    
    
    var currentState:String = ""
    
    
    @IBOutlet weak var searchTextField: UITextField!
    
    
//    var weatherManager = WeatherManager()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tapGR.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tapGR)
      
    }
    
    
    @objc func dismissKeyboard() {
        // キーボードが出現している場合
          if view.isFirstResponder {
            // キーボードを閉じる
            view.endEditing(true)
          }
    }
   
    
    
    //リターンキーを押すと発動する
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
        return true
    }
    
    //UITextFieldの編集が終了する直前に呼び出される
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if searchTextField.text != "" {
            return true
        }else {
            searchTextField.placeholder = "Type something"
            return false
        }
    }
    
    //UITextFieldの編集が終了したときに呼び出される。
    func textFieldDidEndEditing(_ textField: UITextField) {
        //↓これをどうにかしたい。
        inputLocation = searchTextField.text!
        getWether()
        searchTextField.text = ""
        
    }
    
    
    
    
    
    //サーチボタン
    @IBAction func searchButtonAction(_ sender: UIButton) {
        
        if searchTextField.text != "" {
            //↓これをどうにかしたい。
            inputLocation = searchTextField.text!
            getWether()
            searchTextField.endEditing(true)
        }else {
            searchTextField.placeholder = "Type something"
            
        }
        
    }
    

    
    @IBAction func curentWetherAction(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) in
            
            if let error = error {
                print("reverseGeocodeLocation Failed: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?[0] {
                
                
//                locInfo = locInfo + "Latitude: \(loc.coordinate.latitude)\n"
//                locInfo = locInfo + "Longitude: \(loc.coordinate.longitude)\n\n"
                
//                locInfo = locInfo + "Country: \(placemark.country ?? "")\n"
                self.currentState = placemark.administrativeArea ?? ""
                
                self.inputLocation = self.currentState
                self.getWether()
//                locInfo = locInfo + "City: \(placemark.locality ?? "")\n"
//                locInfo = locInfo + "PostalCode: \(placemark.postalCode ?? "")\n"
//                locInfo = locInfo + "Name: \(placemark.name ?? "")"
                
                
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    
    
    public func getWether() {
        Task {
            
            let API_KEY = "29889ccfe8703e3f024730872e58b036"
//            let cityName = "London"
//            let parameter = "lat=\(latitude)&lon=\(longitude)&appid=\(API_KEY)&lang=ja&units=metric"
            
//            https:api.openweathermap.org/data/2.5/weather?q={city name}&appid={API key}
            
            //場所で実行できるようにしたい　例　London
            let url = URL(string: "https:api.openweathermap.org/data/2.5/weather?q=\(self.inputLocation)&appid=\(API_KEY)&lang=ja&units=metric")
            
            let (data,_) = try await URLSession.shared.data(from: url!)
            
            
//            let text = String(data:data, encoding: .utf8)
//            print(data)
//            print(text!)
//            DispatchQueue.main.async {　Taskがあるから使わなくていい
                do {
                    //欲しい値　天気、温度、場所
                    let items = try JSONDecoder().decode(Welcome.self, from: data)
                    let weatherArray = items.weather
                    let mainTemp = items.main.temp
                    let name = items.name
                    
                    for weather in weatherArray {
                        displayWeather = weather.main
                    }
                    
                    if (displayWeather == "Clouds") {
                        let img = UIImage(systemName: "cloud")
                        conditionImageView.image = img
                        
                    }else if (displayWeather == "Rain") {
                        let img = UIImage(systemName: "cloud.rain")
                        conditionImageView.image = img
                    }else if (displayWeather == "Clear") {
                        let img = UIImage(systemName: "sun.max")
                        conditionImageView.image = img
                    } else if (displayWeather == "cloud.snow") {
                        let img = UIImage(systemName: "cloud.rain")
                        conditionImageView.image = img
                    }
                    print(displayWeather)

                    
                    tem = mainTemp
                    temperatureLabel.text = String(format: "%.0f", tem)
                    
                    location = name
                    cityLabel.text = name
                    
                    
                }catch {
                    print(error)
                }

            
            
            
            
        }


}

    // MARK: - Welcome
    struct Welcome: Codable {
        let coord: Coord
        let weather: [Weather]
        let base: String
        let main: Main
        let visibility: Int
        let wind: Wind
        let clouds: Clouds
        let dt: Int
        let sys: Sys
        let timezone, id: Int
        let name: String
        let cod: Int
    }

    // MARK: - Clouds
    struct Clouds: Codable {
        let all: Int
    }

    // MARK: - Coord
    struct Coord: Codable {
        let lon, lat: Double
    }

    // MARK: - Main
    struct Main: Codable {
        let temp, feelsLike, tempMin, tempMax: Double
        let pressure, humidity: Int

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure, humidity
        }
    }

    // MARK: - Sys
    struct Sys: Codable {
        let type, id: Int
        let country: String
        let sunrise, sunset: Int
    }

    // MARK: - Weather
    struct Weather: Codable {
        let id: Int
        let main, description, icon: String
    }

    // MARK: - Wind
    struct Wind: Codable {
        let speed: Double
        let deg: Int
    }
    
}

