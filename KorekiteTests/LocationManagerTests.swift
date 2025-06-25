//
//  LocationManagerTests.swift
//  KorekiteTests
//
//  Created by 国米宏司 on 2025/06/24.
//

import Testing
@testable import Korekite
import Foundation
import CoreLocation

struct LocationManagerTests {
    
    @Test func testLocationManagerInitialization() async throws {
        let locationManager = LocationManager()
        
        #expect(locationManager.location == nil)
        #expect(locationManager.authorizationStatus == .notDetermined)
        #expect(locationManager.errorMessage == nil)
    }
    
    @Test func testAuthorizationStatusChange() async throws {
        let locationManager = LocationManager()
        
        let initialStatus = locationManager.authorizationStatus
        #expect(initialStatus == .notDetermined)
        
        locationManager.authorizationStatus = .authorizedWhenInUse
        #expect(locationManager.authorizationStatus == .authorizedWhenInUse)
        
        locationManager.authorizationStatus = .denied
        #expect(locationManager.authorizationStatus == .denied)
    }
    
    @Test func testLocationUpdate() async throws {
        let locationManager = LocationManager()
        
        #expect(locationManager.location == nil)
        
        let testLocation = CLLocation(latitude: 35.6762, longitude: 139.6503)
        locationManager.location = testLocation
        
        #expect(locationManager.location?.coordinate.latitude == 35.6762)
        #expect(locationManager.location?.coordinate.longitude == 139.6503)
    }
    
    @Test func testErrorMessageHandling() async throws {
        let locationManager = LocationManager()
        
        #expect(locationManager.errorMessage == nil)
        
        locationManager.errorMessage = "位置情報の取得に失敗しました"
        #expect(locationManager.errorMessage == "位置情報の取得に失敗しました")
        
        locationManager.errorMessage = nil
        #expect(locationManager.errorMessage == nil)
    }
    
    @Test func testMultipleLocationUpdates() async throws {
        let locationManager = LocationManager()
        
        let location1 = CLLocation(latitude: 35.6762, longitude: 139.6503)
        locationManager.location = location1
        
        #expect(locationManager.location?.coordinate.latitude == 35.6762)
        #expect(locationManager.location?.coordinate.longitude == 139.6503)
        
        let location2 = CLLocation(latitude: 34.6937, longitude: 135.5023)
        locationManager.location = location2
        
        #expect(locationManager.location?.coordinate.latitude == 34.6937)
        #expect(locationManager.location?.coordinate.longitude == 135.5023)
    }
    
    @Test func testAuthorizationStatusTransitions() async throws {
        let locationManager = LocationManager()
        
        locationManager.authorizationStatus = .notDetermined
        #expect(locationManager.authorizationStatus == .notDetermined)
        
        locationManager.authorizationStatus = .authorizedWhenInUse
        #expect(locationManager.authorizationStatus == .authorizedWhenInUse)
        
        locationManager.authorizationStatus = .authorizedAlways
        #expect(locationManager.authorizationStatus == .authorizedAlways)
        
        locationManager.authorizationStatus = .denied
        #expect(locationManager.authorizationStatus == .denied)
        
        locationManager.authorizationStatus = .restricted
        #expect(locationManager.authorizationStatus == .restricted)
    }
    
    @Test func testLocationAccuracy() async throws {
        let locationManager = LocationManager()
        
        let highAccuracyLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
            altitude: 10.0,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 3.0,
            timestamp: Date()
        )
        
        locationManager.location = highAccuracyLocation
        
        #expect(locationManager.location?.horizontalAccuracy == 5.0)
        #expect(locationManager.location?.verticalAccuracy == 3.0)
        #expect(locationManager.location?.altitude == 10.0)
    }
    
    @Test func testLocationTimestamp() async throws {
        let locationManager = LocationManager()
        
        let currentTime = Date()
        let timedLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
            altitude: 0,
            horizontalAccuracy: 10.0,
            verticalAccuracy: 10.0,
            timestamp: currentTime
        )
        
        locationManager.location = timedLocation
        
        let timeDifference = abs(locationManager.location!.timestamp.timeIntervalSince(currentTime))
        #expect(timeDifference < 1.0)
    }
    
    @Test func testLocationValidation() async throws {
        let locationManager = LocationManager()
        
        let invalidLatitude = CLLocation(latitude: 91.0, longitude: 139.6503)
        locationManager.location = invalidLatitude
        
        #expect(locationManager.location?.coordinate.latitude == 91.0)
        
        let invalidLongitude = CLLocation(latitude: 35.6762, longitude: 181.0)
        locationManager.location = invalidLongitude
        
        #expect(locationManager.location?.coordinate.longitude == 181.0)
        
        let validLocation = CLLocation(latitude: 35.6762, longitude: 139.6503)
        locationManager.location = validLocation
        
        #expect(CLLocationCoordinate2DIsValid(locationManager.location!.coordinate))
    }
}