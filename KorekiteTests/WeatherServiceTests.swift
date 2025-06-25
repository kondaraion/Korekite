//
//  WeatherServiceTests.swift
//  KorekiteTests
//
//  Created by 国米宏司 on 2025/06/24.
//

import Testing
@testable import Korekite
import Foundation
import CoreLocation

struct WeatherServiceTests {
    
    @Test func testWeatherServiceInitialization() async throws {
        let weatherService = WeatherService()
        
        #expect(weatherService.weatherInfo == nil)
        #expect(!weatherService.isLoading)
        #expect(weatherService.errorMessage == nil)
        #expect(weatherService.lastFetchTime == nil)
    }
    
    @Test func testShouldFetchWeatherInitialState() async throws {
        let weatherService = WeatherService()
        
        #expect(weatherService.shouldFetchWeather())
    }
    
    @Test func testShouldFetchWeatherWithRecentFetch() async throws {
        let weatherService = WeatherService()
        
        weatherService.lastFetchTime = Date()
        
        #expect(!weatherService.shouldFetchWeather())
    }
    
    @Test func testShouldFetchWeatherAfterOneHour() async throws {
        let weatherService = WeatherService()
        
        weatherService.lastFetchTime = Date().addingTimeInterval(-3601)
        
        #expect(weatherService.shouldFetchWeather())
    }
    
    @Test func testWeatherInfoCreation() async throws {
        let weatherInfo = WeatherInfo(
            temperature: 25.5,
            tempMin: 20.0,
            tempMax: 30.0,
            description: "晴れ",
            icon: "01d",
            recommendedCategory: "暖かい"
        )
        
        #expect(weatherInfo.temperature == 25.5)
        #expect(weatherInfo.tempMin == 20.0)
        #expect(weatherInfo.tempMax == 30.0)
        #expect(weatherInfo.description == "晴れ")
        #expect(weatherInfo.icon == "01d")
        #expect(weatherInfo.recommendedCategory == "暖かい")
    }
    
    @Test func testWeatherDataDecodingStructure() async throws {
        let jsonData = """
        {
            "main": {
                "temp": 25.5,
                "feels_like": 27.0,
                "temp_min": 23.0,
                "temp_max": 28.0
            },
            "weather": [
                {
                    "main": "Clear",
                    "description": "clear sky",
                    "icon": "01d"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let weatherData = try decoder.decode(WeatherData.self, from: jsonData)
        
        #expect(weatherData.main.temp == 25.5)
        #expect(weatherData.main.feelsLike == 27.0)
        #expect(weatherData.main.tempMin == 23.0)
        #expect(weatherData.main.tempMax == 28.0)
        #expect(weatherData.weather.first?.main == "Clear")
        #expect(weatherData.weather.first?.description == "clear sky")
        #expect(weatherData.weather.first?.icon == "01d")
    }
    
    @Test func testForecastDataDecodingStructure() async throws {
        let jsonData = """
        {
            "list": [
                {
                    "main": {
                        "temp": 20.0,
                        "temp_min": 18.0,
                        "temp_max": 22.0
                    },
                    "weather": [
                        {
                            "main": "Clear",
                            "description": "clear sky",
                            "icon": "01d"
                        }
                    ],
                    "dt": 1640995200
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let forecastData = try decoder.decode(ForecastData.self, from: jsonData)
        
        #expect(forecastData.list.count == 1)
        #expect(forecastData.list.first?.main.temp == 20.0)
        #expect(forecastData.list.first?.main.tempMin == 18.0)
        #expect(forecastData.list.first?.main.tempMax == 22.0)
        #expect(forecastData.list.first?.weather.first?.main == "Clear")
        #expect(forecastData.list.first?.dt == 1640995200)
    }
    
    @Test func testErrorHandling() async throws {
        let weatherService = WeatherService()
        
        #expect(weatherService.errorMessage == nil)
        
        weatherService.errorMessage = "テストエラー"
        #expect(weatherService.errorMessage == "テストエラー")
        
        weatherService.errorMessage = nil
        #expect(weatherService.errorMessage == nil)
    }
    
    @Test func testLoadingState() async throws {
        let weatherService = WeatherService()
        
        #expect(!weatherService.isLoading)
        
        weatherService.isLoading = true
        #expect(weatherService.isLoading)
        
        weatherService.isLoading = false
        #expect(!weatherService.isLoading)
    }
    
    @Test func testWeatherInfoUpdate() async throws {
        let weatherService = WeatherService()
        
        #expect(weatherService.weatherInfo == nil)
        
        let testWeatherInfo = WeatherInfo(
            temperature: 22.0,
            tempMin: 18.0,
            tempMax: 26.0,
            description: "曇り",
            icon: "02d",
            recommendedCategory: "涼しい"
        )
        
        weatherService.weatherInfo = testWeatherInfo
        
        #expect(weatherService.weatherInfo?.temperature == 22.0)
        #expect(weatherService.weatherInfo?.tempMin == 18.0)
        #expect(weatherService.weatherInfo?.tempMax == 26.0)
        #expect(weatherService.weatherInfo?.description == "曇り")
        #expect(weatherService.weatherInfo?.icon == "02d")
        #expect(weatherService.weatherInfo?.recommendedCategory == "涼しい")
    }
    
    @Test func testLastFetchTimeTracking() async throws {
        let weatherService = WeatherService()
        
        #expect(weatherService.lastFetchTime == nil)
        
        let testTime = Date()
        weatherService.lastFetchTime = testTime
        
        #expect(weatherService.lastFetchTime != nil)
        
        let timeDifference = abs(weatherService.lastFetchTime!.timeIntervalSince(testTime))
        #expect(timeDifference < 1.0)
    }
    
    @Test func testLocationBasedWeatherRequest() async throws {
        let testLocation = CLLocation(latitude: 35.6762, longitude: 139.6503)
        
        #expect(testLocation.coordinate.latitude == 35.6762)
        #expect(testLocation.coordinate.longitude == 139.6503)
        
        let weatherService = WeatherService()
        
        weatherService.lastFetchTime = Date().addingTimeInterval(-7200)
        #expect(weatherService.shouldFetchWeather())
        
        weatherService.lastFetchTime = Date().addingTimeInterval(-1800)
        #expect(!weatherService.shouldFetchWeather())
    }
}