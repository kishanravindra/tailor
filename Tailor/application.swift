import Foundation

/**
  This class provides the application for the Haberdashery.
  */
class HaberdasheryApplication : Application {
  required init(){
    super.init()
    self.routeSet = HaberdasheryRouteSet
  }
}