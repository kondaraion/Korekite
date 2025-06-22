import Foundation
import CoreLocation

struct WeatherData: Codable {
    let main: Main
    let weather: [Weather]
    
    struct Main: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
        }
    }
    
    struct Weather: Codable {
        let main: String
        let description: String
        let icon: String
    }
}

struct WeatherInfo {
    let temperature: Double
    let tempMin: Double
    let tempMax: Double
    let description: String
    let icon: String
    let recommendedCategory: String
}

class WeatherService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    init() {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path),
           let key = config["OpenWeatherMapAPIKey"] as? String {
            self.apiKey = key
        } else {
            self.apiKey = ""
            print("⚠️ OpenWeatherMap API key not found. Please add Config.plist with OpenWeatherMapAPIKey")
        }
    }
    
    @Published var weatherInfo: WeatherInfo?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchWeather(for location: CLLocation) {
        isLoading = true
        errorMessage = nil
        
        let urlString = "\(baseURL)?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric&lang=ja"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "無効なURLです"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "天気情報の取得に失敗しました: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "データの取得に失敗しました"
                    return
                }
                
                do {
                    let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                    let recommendedCategory = self?.getRecommendedCategory(
                        tempMin: weatherData.main.tempMin,
                        tempMax: weatherData.main.tempMax
                    ) ?? "暖かい"
                    
                    self?.weatherInfo = WeatherInfo(
                        temperature: weatherData.main.temp,
                        tempMin: weatherData.main.tempMin,
                        tempMax: weatherData.main.tempMax,
                        description: weatherData.weather.first?.description ?? "",
                        icon: weatherData.weather.first?.icon ?? "",
                        recommendedCategory: recommendedCategory
                    )
                } catch {
                    self?.errorMessage = "天気データの解析に失敗しました: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    private func getRecommendedCategory(tempMin: Double, tempMax: Double) -> String {
        // 最低気温と最高気温の組み合わせで判断
        let avgTemp = (tempMin + tempMax) / 2
        let tempRange = tempMax - tempMin
        
        // 気温差が大きい場合（10度以上）は中間の温度に合わせる
        if tempRange >= 10 {
            // 朝晩の寒暖差が大きい場合は重ね着を推奨
            switch avgTemp {
            case ...5:
                return "寒い"  // 重ね着で調整
            case 5...15:
                return "涼しい"  // 重ね着で調整
            case 15...25:
                return "暖かい"  // 重ね着で調整
            default:
                return "暑い"  // 軽装で調整
            }
        } else {
            // 寒暖差が小さい場合は最高気温を重視
            switch tempMax {
            case ...0:
                return "極寒"
            case 0...10:
                return "寒い"
            case 10...20:
                return "涼しい"
            case 20...28:
                return "暖かい"
            case 28...35:
                return "暑い"
            default:
                return "猛暑"
            }
        }
    }
}