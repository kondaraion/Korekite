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

struct ForecastData: Codable {
    let list: [ForecastItem]
    
    struct ForecastItem: Codable {
        let main: Main
        let weather: [Weather]
        let dt: TimeInterval
        
        struct Main: Codable {
            let temp: Double
            let tempMin: Double
            let tempMax: Double
            
            enum CodingKeys: String, CodingKey {
                case temp
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
    private let weatherBaseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let forecastBaseURL = "https://api.openweathermap.org/data/2.5/forecast"
    @Published var lastFetchTime: Date?
    
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
    
    // 1時間以内に取得済みかどうかをチェック
    func shouldFetchWeather() -> Bool {
        guard let lastFetch = lastFetchTime else {
            return true // 初回取得
        }
        
        let oneHourAgo = Date().addingTimeInterval(-3600) // 1時間前
        return lastFetch < oneHourAgo
    }
    
    func fetchWeather(for location: CLLocation) {
        // 1時間以内に取得済みの場合は何もしない
        if !shouldFetchWeather() {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // 現在の天気と予報を並行して取得
        let group = DispatchGroup()
        var currentWeather: WeatherData?
        var forecastData: ForecastData?
        var weatherError: String?
        var forecastError: String?
        
        // 現在の天気を取得
        group.enter()
        fetchCurrentWeather(for: location) { result in
            switch result {
            case .success(let weather):
                currentWeather = weather
            case .failure(let error):
                weatherError = error.localizedDescription
            }
            group.leave()
        }
        
        // 予報を取得
        group.enter()
        fetchForecast(for: location) { result in
            switch result {
            case .success(let forecast):
                forecastData = forecast
            case .failure(let error):
                forecastError = error.localizedDescription
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            
            // エラーハンドリング
            if let weatherError = weatherError, let forecastError = forecastError {
                self?.errorMessage = "天気情報の取得に失敗しました: \(weatherError), \(forecastError)"
                return
            }
            
            guard let currentWeather = currentWeather else {
                self?.errorMessage = "現在の天気情報の取得に失敗しました"
                return
            }
            
            // 予報データから今日の最高・最低気温を計算
            let todayMinMax = self?.calculateTodayMinMax(from: forecastData)
            
            let recommendedCategory = self?.getRecommendedCategory(
                tempMin: todayMinMax?.min ?? currentWeather.main.temp,
                tempMax: todayMinMax?.max ?? currentWeather.main.temp
            ) ?? "暖かい"
            
            self?.weatherInfo = WeatherInfo(
                temperature: currentWeather.main.temp,
                tempMin: todayMinMax?.min ?? currentWeather.main.temp,
                tempMax: todayMinMax?.max ?? currentWeather.main.temp,
                description: currentWeather.weather.first?.description ?? "",
                icon: currentWeather.weather.first?.icon ?? "",
                recommendedCategory: recommendedCategory
            )
            
            // 取得時刻を記録
            self?.lastFetchTime = Date()
        }
    }
    
    // 強制的に天気データを再取得するメソッド
    func refreshWeather(for location: CLLocation) {
        isLoading = true
        errorMessage = nil
        
        // 現在の天気と予報を並行して取得
        let group = DispatchGroup()
        var currentWeather: WeatherData?
        var forecastData: ForecastData?
        var weatherError: String?
        var forecastError: String?
        
        // 現在の天気を取得
        group.enter()
        fetchCurrentWeather(for: location) { result in
            switch result {
            case .success(let weather):
                currentWeather = weather
            case .failure(let error):
                weatherError = error.localizedDescription
            }
            group.leave()
        }
        
        // 予報を取得
        group.enter()
        fetchForecast(for: location) { result in
            switch result {
            case .success(let forecast):
                forecastData = forecast
            case .failure(let error):
                forecastError = error.localizedDescription
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            
            // エラーハンドリング
            if let weatherError = weatherError, let forecastError = forecastError {
                self?.errorMessage = "天気情報の取得に失敗しました: \(weatherError), \(forecastError)"
                return
            }
            
            guard let currentWeather = currentWeather else {
                self?.errorMessage = "現在の天気情報の取得に失敗しました"
                return
            }
            
            // 予報データから今日の最高・最低気温を計算
            let todayMinMax = self?.calculateTodayMinMax(from: forecastData)
            
            let recommendedCategory = self?.getRecommendedCategory(
                tempMin: todayMinMax?.min ?? currentWeather.main.temp,
                tempMax: todayMinMax?.max ?? currentWeather.main.temp
            ) ?? "暖かい"
            
            self?.weatherInfo = WeatherInfo(
                temperature: currentWeather.main.temp,
                tempMin: todayMinMax?.min ?? currentWeather.main.temp,
                tempMax: todayMinMax?.max ?? currentWeather.main.temp,
                description: currentWeather.weather.first?.description ?? "",
                icon: currentWeather.weather.first?.icon ?? "",
                recommendedCategory: recommendedCategory
            )
            
            // 取得時刻を記録
            self?.lastFetchTime = Date()
        }
    }
    
    // 現在の天気を取得
    private func fetchCurrentWeather(for location: CLLocation, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let urlString = "\(weatherBaseURL)?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric&lang=ja"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "WeatherService", code: 1, userInfo: [NSLocalizedDescriptionKey: "無効なURLです"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "WeatherService", code: 2, userInfo: [NSLocalizedDescriptionKey: "データの取得に失敗しました"])))
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                completion(.success(weatherData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // 予報を取得
    private func fetchForecast(for location: CLLocation, completion: @escaping (Result<ForecastData, Error>) -> Void) {
        let urlString = "\(forecastBaseURL)?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric&lang=ja"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "WeatherService", code: 1, userInfo: [NSLocalizedDescriptionKey: "無効なURLです"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "WeatherService", code: 2, userInfo: [NSLocalizedDescriptionKey: "データの取得に失敗しました"])))
                return
            }
            
            do {
                let forecastData = try JSONDecoder().decode(ForecastData.self, from: data)
                completion(.success(forecastData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // 予報データから今日の最高・最低気温を計算
    private func calculateTodayMinMax(from forecastData: ForecastData?) -> (min: Double, max: Double)? {
        guard let forecastData = forecastData else { return nil }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // 今日の予報データをフィルタリング
        let todayForecasts = forecastData.list.filter { item in
            let itemDate = Date(timeIntervalSince1970: item.dt)
            return itemDate >= today && itemDate < tomorrow
        }
        
        guard !todayForecasts.isEmpty else { return nil }
        
        // 最高・最低気温を計算
        let minTemp = todayForecasts.map { $0.main.tempMin }.min() ?? 0
        let maxTemp = todayForecasts.map { $0.main.tempMax }.max() ?? 0
        
        return (min: minTemp, max: maxTemp)
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