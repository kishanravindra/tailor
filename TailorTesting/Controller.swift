import Tailor

@available(*, deprecated) public extension Controller {
  /**
    This method initializes a controller with a dummy request, action, and
    callback.
    */
  public convenience init() {
    self.init(request: Request(), actionName: "index", callback: {_ in })
  }
}