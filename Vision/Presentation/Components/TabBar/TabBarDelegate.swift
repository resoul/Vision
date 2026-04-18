import Foundation

protocol TabBarDelegate: AnyObject {
    func tabBar(_ tabBar: TabBarView, didSelectItem item: TabItem)
    func tabBar(_ tabBar: TabBarView, didSelectGenre genre: GenreItem, inItem item: TabItem)
    func tabBarDidSelectSearch(_ tabBar: TabBarView)
    func tabBarDidSelectSettings(_ tabBar: TabBarView)
}
