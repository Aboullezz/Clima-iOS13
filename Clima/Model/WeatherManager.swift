//
//  WeatherManager.swift
//  Clima
//
//  Created by Mohamed Aboullezz on 03/01/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}
struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=83e8fd4f41acc3e1507ad24e15fe094e&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    
    func fetchWeather (cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        //print(urlString)
        performResquest(with: urlString)
    }
    
    func fetchWeather (latitude: CLLocationDegrees , longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performResquest(with: urlString)
//        print(urlString)
    }
    
    func performResquest(with urlString: String) {
            //1. creat a URL
        if let url = URL(string: urlString) {
            //2. creat a URL Session
            let session = URLSession(configuration: .default)
            //3. Give the Session a Task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    //print(error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                        //print(safeData)
                    }
                }
            }
            //4. Start the Task
            task.resume()
        }
    }
    
    func parseJSON (_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
          let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
          let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
//            print(error)
            return nil
            }
    }
    
}
