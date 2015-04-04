import Tailor

public extension Controller {
  /**
    This method initializes a controller with a dummy request, action, and
    callback.
    */
  public convenience init() {
    self.init(request: Request(), action: "index", callback: {_ in })
  }
}