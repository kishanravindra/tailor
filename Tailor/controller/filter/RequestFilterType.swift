/**
  This type describes a filter that can be applied before and after processing
  a request.

  The filter may modify the response and pass it on to the next step of the
  flow. Once the preprocessors have stopped, the processing will go through all
  the filters in reverse older, running their postprocessors.
  */
public protocol RequestFilterType {
  /**
    This method contains the filter's preprocessing logic.

    - parameter request:    The request that we are processing.
    - parameter response:   The response so far
    - parameter callback:   The callback to call with the modified response, and
                            a flag indicating that we should stop processing any
                            more filters.
    */
  func preProcess(request: Request, response: Response, callback: (Response, stop: Bool)->Void)
  
  /**
    This method contains the filter's postprocessing logic.

    - parameter request:    The request that we are processing.
    - parameter response:   The response so far.
    - parameter callback:   The callback to call with the modified response.
    */
  func postProcess(request: Request, response: Response, callback: (Response)->Void)
}