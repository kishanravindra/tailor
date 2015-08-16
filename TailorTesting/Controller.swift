import Tailor

@available(*, deprecated) public extension Controller {
  /**
    This method initializes a controller with a dummy request, action, and
    callback.
    */
  public convenience init() {
    self.init(request: Request(), response: Response(), actionName: "index", callback: {_ in })
  }
}