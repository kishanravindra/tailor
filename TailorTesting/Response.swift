import Tailor
extension Response {
  /** A session built from the response's cookies. */
  public var session: Session {
    return Request(cookies: cookies.cookieDictionary()).session
  }
}