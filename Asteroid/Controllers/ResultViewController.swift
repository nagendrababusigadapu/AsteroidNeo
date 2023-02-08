//
//  SecondViewController.swift
//  Asteroid
//
//  Created by Nagendra Babu Sigadapu on 07/02/23.
//

import UIKit
import Charts

class ResultViewController: UITableViewController {
    
    //MARK: - IBOutlets
    
    ///fastest Astroid outlets
    @IBOutlet weak var fastestAstroidID: UILabel!
    @IBOutlet weak var fastestAstroidName: UILabel!
    @IBOutlet weak var fastestAstroidSpeed: UILabel!
    
    ///closest Astroid outlets
    @IBOutlet weak var closestAstroidID: UILabel!
    @IBOutlet weak var closestAstroidName: UILabel!
    @IBOutlet weak var closestAstroidDistance: UILabel!
    
    ///Size Astroid outlets
    @IBOutlet weak var sizeOfAstroid: UILabel!
    
    ///Chart outlets
    @IBOutlet weak var barChartView: BarChartView!
    
    //MARK: - Properties
    
    var searchVM:SearchViewModel? = nil
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configTableVIew()
        setupUI()
        updateUI()
        prepareDataForChart()
    }
    
    //MARK: - deinit
    
    deinit{}

}

//MARK: - UI Methods
/// handling Update UI

extension ResultViewController {
    
    func configTableVIew(){
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    func setupUI(){
        self.title = "statistics"
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func updateUI(){
        
        if let fastestAstroid = searchVM?.fetchFastestAsteroidInKMH(), let closestAstroid = searchVM?.fetchClosestAsteroidInDistance(), let size = searchVM?.fetchAverageSizeOfTheAsteroidsInKM() {
            
            DispatchQueue.main.async { [weak self] in
                self?.fastestAstroidID.text = fastestAstroid.id
                self?.fastestAstroidName.text = fastestAstroid.name
                self?.fastestAstroidSpeed.text = fastestAstroid.closeApproachData.first?.relativeVelocity.kilometersPerHour
                
                self?.closestAstroidID.text = closestAstroid.id
                self?.closestAstroidName.text = closestAstroid.name
                self?.closestAstroidDistance.text = closestAstroid.closeApproachData.first?.missDistance.kilometers
                
                self?.sizeOfAstroid.text = size.toString()
            }
        }
    }
}


//MARK: - Charts
/// handling charts

extension ResultViewController {
    
    /// handling data for the chart
    private func prepareDataForChart(){
        let dates = [searchVM?.startDate ?? "", searchVM?.endDate ?? ""].compactMap({ $0 })
        let xAxisValues = searchVM?.fetchTotalNumberOfAstroidsInEachDay()
        
        if let xAxisValues = xAxisValues {
            if dates.count == xAxisValues.count {
                setChart(dates: dates, astroidsCount: xAxisValues)
            }
        }
    }
    
    /// Bar chart UI
    func configBarChart(){
        barChartView.noDataText = Constants.chartNoDataMessage
        barChartView.animate(yAxisDuration: 2.0)
        barChartView.pinchZoomEnabled = false
        barChartView.drawBarShadowEnabled = false
        barChartView.drawBordersEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.drawGridBackgroundEnabled = true
    }
    
    func setChart(dates: [String], astroidsCount count: [Int]) {
        
        configBarChart()
        
        var dataEntries: [BarChartDataEntry] = []
        
        let xAxis = barChartView.xAxis
        let leftAxis = barChartView.leftAxis
        let rightAxis = barChartView.rightAxis
        
        let avenirForTweleve = UIFont (name: "Avenir Next Regular", size: 12) ?? UIFont()
        let avenirForSixteen = UIFont (name: "Avenir Next Bold", size: 16) ?? UIFont()
        
        for i in 0..<dates.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(count[i]))
                dataEntries.append(dataEntry)
        }
        
        xAxis.valueFormatter = IndexAxisValueFormatter(values: dates.map({ $0 }))
        xAxis.labelRotationAngle = -25
        xAxis.setLabelCount(dates.count, force: false)
        xAxis.labelTextColor = .white
        xAxis.labelFont = avenirForTweleve
        
        leftAxis.labelFont = avenirForTweleve
        leftAxis.labelTextColor = .white
        
        /// handling y-axis graph based on total number of asteroids counts in each day.
        /// here we are sorting array in ascending order to show minimum and maximum axis values
        if count.count >= 2 {
            let sortResult = count.sorted { a, b in
                return a < b
            }
            
            let axisMin = Double((sortResult.first ?? 0) - 1)
            let axisMax = Double(sortResult.last ?? 0) + 1
            
            leftAxis.setLabelCount(6, force: true)
            leftAxis.calculate(min: axisMin, max: axisMax)
            leftAxis.drawAxisLineEnabled = false
        }
        
        
        rightAxis.enabled = false
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label:Constants.chartLabel)
        chartDataSet.valueFont = avenirForSixteen
        chartDataSet.valueTextColor = .black
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
    }
}

//MARK: - UITableviewDelegate Methods

extension ResultViewController {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .zero
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .zero
    }
}
