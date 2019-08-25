import UIKit
import MapKit

protocol LocationSearchDelegate {
    func selectLocation(_ searchVC: LocationSearchVC, selectedLocation location: (MKMapItem, MKPlacemark))
}

class LocationSearchVC: UIViewController {
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchFormField: UISearchBar!
    @IBOutlet weak var cancelButton: UIButton!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    var locSearchDelegate: LocationSearchDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
        searchFormField.setPlaceholderTextColorTo(color: .black)
        searchFormField.setMagnifyingGlassColorTo(color: .black)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension LocationSearchVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

extension LocationSearchVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension LocationSearchVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
}

extension LocationSearchVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let mapItem = response?.mapItems[0] else { return }
            let _ = mapItem.placemark.coordinate
            self.dismiss(animated: true, completion: {
                self.locSearchDelegate?.selectLocation(self, selectedLocation: (mapItem, mapItem.placemark))
            })
        }
    }
}

extension UISearchBar {
    func setPlaceholderTextColorTo(color: UIColor) {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = color
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = color
    }
    
    func setMagnifyingGlassColorTo(color: UIColor) {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = color
    }
}
