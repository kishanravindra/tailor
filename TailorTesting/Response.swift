import Tailor
extension Response {
  /** A session built from the response's cookies. */
  public var session: Session {
    return Session(request: Request(cookies: cookies.cookieDictionary()))
  }
}