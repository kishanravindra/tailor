/**
  This enum holds errors that can occur when extracting a data structure from
  JSON.

  This has been deprecated in favor of SerializationParsingError.
  */
@available(*, deprecated, message="Use SerializationParsingError instead")
public typealias JsonParsingError = SerializationParsingError

/**
  This enum holds errors that can occur when converting a data structure into
  JSON.
 
  This has been deprecated in favor of JsonConversionError.
  */
@available(*, deprecated)
public typealias JsonConversionError = SerializationConversionError