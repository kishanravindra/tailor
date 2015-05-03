import Tailor
class ___PACKAGENAME___Application : Application {
  required init(){
    super.init()
    self.routeSet = ___PACKAGENAME___RouteSet()
  }
  
  override func rootPath() -> String {
    return "___PACKAGENAME___.app/Contents/Resources"
  }
}