//
//  SearchViewModel.swift
//  Asteroid
//
//  Created by Nagendra Babu Sigadapu on 07/02/23.
//

import Foundation

class SearchViewModel {
    
    private let astroidUrlPath = "https://api.nasa.gov/neo/rest/v1/feed"
    private let apiKey = "pilRX23gQSeWzetqvpiUnMLJtZwCb822jnzpb1XS"
    private var combinedResult:[NearEarthObject]?
    private var astroidData:AstroidData? = nil
    
    private var prepareParameters:[String:Any] {
        get{
            let parameters: [String:Any] = [
                "start_date": startDate,
                "end_date" : endDate,
                "api_key" : apiKey
                ]
            return parameters
        }
    }
    
    var startDate:String = ""
    var endDate:String = ""
    
    /// fetch data from api
    func fetchData(completion : @escaping (_ isSuccess: Bool,_ error:String?) -> Void){
        APIService.shared.requestGETURL(urlString: astroidUrlPath, parameters: prepareParameters) { [weak self] (response:AstroidData) in
            let status = self?.updateResponse(response: response)
            if status ?? false {
                completion(true,nil)
            }else{
                completion(false,Constants.globalMessage)
            }
        } failure: { (message) in
            completion(false, message)
        }
    }
}

extension SearchViewModel {
    
    /// handling response
    func updateResponse(response:AstroidData) -> Bool {
        self.astroidData = response
        guard let result1 = response.nearEarthObjects[startDate], let result2 = response.nearEarthObjects[endDate] else{
            return false
        }
        combinedResult = [result1, result2].joined().compactMap ({ $0 })
        return true
    }
    
    /// calculating Fastest Astroid in km/h
    func fetchFastestAsteroidInKMH() -> NearEarthObject? {
        let fastestAstroid = combinedResult?.sorted { a, b in
            return a.closeApproachData.first?.relativeVelocity.kilometersPerHour ?? "0.0" > b.closeApproachData.first?.relativeVelocity.kilometersPerHour ?? "0.0"
        }
        return fastestAstroid?.first
    }
    
    /// calculating closest Astroid in distance
    func fetchClosestAsteroidInDistance() -> NearEarthObject? {
        let closestAstroid = combinedResult?.sorted { a, b in
            return a.closeApproachData.first?.missDistance.kilometers ?? "0.0" < b.closeApproachData.first?.missDistance.kilometers ?? "0.0"
        }
        return closestAstroid?.first
    }
    
    /// calculating average size of the asteroids in kilometers
    func fetchAverageSizeOfTheAsteroidsInKM() -> Double? {
        
        guard let combinedResult = combinedResult else { return 0.0 }
        
        let minimumDiameter = combinedResult.map({ Double($0.estimatedDiameter.kilometers.estimatedDiameterMin) }).reduce(0,+)
        let maximumDiameter = combinedResult.map({ Double($0.estimatedDiameter.kilometers.estimatedDiameterMax) }).reduce(0,+)
        
        let totalCount = Double(fetchNumberOfAstroidsCountInGivenDateRange())
        
        let result = (minimumDiameter + maximumDiameter) / totalCount
        
        return result
    }
    
    ///handling total asteroids count
    func fetchNumberOfAstroidsCountInGivenDateRange() -> Int {
        return astroidData?.elementCount ?? 0
    }
    
    ///handling astroid data as global property
    func fetchAstroidData() -> AstroidData? {
        guard let data = astroidData else {
            return nil
        }
        return data
    }
    
    ///handling astroid count in each day in the given date range
    func fetchTotalNumberOfAstroidsInEachDay() -> [Int]? {
        guard let result1 = self.astroidData?.nearEarthObjects[startDate], let result2 = self.astroidData?.nearEarthObjects[endDate] else{
            return []
        }
        let resultOneCount = result1.count
        let resultTwoCount = result2.count
        
        return [resultOneCount,resultTwoCount]
    }
    
}
